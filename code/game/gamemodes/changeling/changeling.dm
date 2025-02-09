/datum/game_mode/changeling
	name = "changeling"
	config_tag = "changeling"
	report_type = "changeling"
	role_preference = /datum/role_preference/antagonist/changeling
	antag_datum = /datum/antagonist/changeling
	false_report_weight = 10
	restricted_jobs = list(JOB_NAME_AI, JOB_NAME_CYBORG)
	protected_jobs = list(JOB_NAME_SECURITYOFFICER, JOB_NAME_WARDEN, JOB_NAME_DETECTIVE, JOB_NAME_HEADOFSECURITY, JOB_NAME_CAPTAIN)
	required_players = 15
	required_enemies = 1
	recommended_enemies = 4
	reroll_friendly = 1

	announce_span = "green"
	announce_text = "Alien changelings have infiltrated the crew!\n \
	" + span_green("Changelings") + ": Accomplish your objectives.\n \
	" + span_notice("Crew") + ": Root out and eliminate the changeling menace!"

	title_icon = "changeling"

	var/const/changeling_amount = 4 //hard limit on changelings if scaling is turned off
	var/list/changelings = list()

/datum/game_mode/changeling/pre_setup()

	if(CONFIG_GET(flag/protect_roles_from_antagonist))
		restricted_jobs += protected_jobs

	if(CONFIG_GET(flag/protect_assistant_from_antagonist))
		restricted_jobs += JOB_NAME_ASSISTANT

	if(CONFIG_GET(flag/protect_heads_from_antagonist))
		restricted_jobs += SSdepartment.get_jobs_by_dept_id(DEPT_NAME_COMMAND)

	var/num_changelings = 1

	var/csc = CONFIG_GET(number/changeling_scaling_coeff)
	if(csc)
		num_changelings = max(1, min(round(num_players() / (csc * 2)) + 2, round(num_players() / csc)))
	else
		num_changelings = max(1, min(num_players(), changeling_amount))

	if(antag_candidates.len>0)
		for(var/i = 0, i < num_changelings, i++)
			if(!antag_candidates.len)
				break
			var/datum/mind/changeling = antag_pick(antag_candidates, /datum/role_preference/antagonist/changeling)
			antag_candidates -= changeling
			changelings += changeling
			changeling.special_role = ROLE_CHANGELING
			changeling.restricted_roles = restricted_jobs
			GLOB.pre_setup_antags += changeling
		return TRUE
	else
		setup_error = "Not enough changeling candidates"
		return FALSE

/datum/game_mode/changeling/post_setup()
	for(var/datum/mind/changeling in changelings)
		log_game("[key_name(changeling)] has been selected as a changeling")
		var/datum/antagonist/changeling/new_antag = new()
		changeling.add_antag_datum(new_antag)
		GLOB.pre_setup_antags -= changeling
	..()

/datum/game_mode/changeling/make_antag_chance(mob/living/carbon/human/character) //Assigns changeling to latejoiners
	var/csc = CONFIG_GET(number/changeling_scaling_coeff)
	var/changelingcap = min(round(GLOB.joined_player_list.len / (csc * 2)) + 2, round(GLOB.joined_player_list.len / csc))
	if(changelings.len >= changelingcap) //Caps number of latejoin antagonists
		return
	if(changelings.len <= (changelingcap - 2) || prob(100 - (csc * 2)))
		if(!QDELETED(character) && character.client?.should_include_for_role(
			banning_key = initial(antag_datum.banning_key),
			role_preference_key = role_preference,
			req_hours = initial(antag_datum.required_living_playtime)
		))
			if(!(character.job in restricted_jobs))
				character.mind.make_Changeling()
				changelings += character.mind

/datum/game_mode/changeling/generate_report()
	return "The Gorlex Marauders have announced the successful raid and destruction of Central Command containment ship #S-[rand(1111, 9999)]. This ship housed only a single prisoner - \
			codenamed \"Thing\", and it was highly adaptive and extremely dangerous. We have reason to believe that the Thing has allied with the Syndicate, and you should note that likelihood \
			of the Thing being sent to a station in this sector is highly likely. It may be in the guise of any crew member. Trust nobody - suspect everybody. Do not announce this to the crew, \
			as paranoia may spread and inhibit workplace efficiency."

//////////////////////////////////////////
//Checks to see if someone is changeling//
//////////////////////////////////////////
/proc/is_changeling(mob/M)
	return M?.mind?.has_antag_datum(/datum/antagonist/changeling)

/datum/antagonist/changeling/proc/transform(mob/living/carbon/human/user, datum/changelingprofile/chosen_prof)
	var/static/list/slot2slot = list(
		"head" = ITEM_SLOT_HEAD,
		"wear_mask" = ITEM_SLOT_MASK,
		"neck" = ITEM_SLOT_NECK,
		"back" = ITEM_SLOT_BACK,
		"wear_suit" = ITEM_SLOT_OCLOTHING,
		"w_uniform" = ITEM_SLOT_ICLOTHING,
		"shoes" = ITEM_SLOT_FEET,
		"belt" = ITEM_SLOT_BELT,
		"gloves" = ITEM_SLOT_GLOVES,
		"glasses" = ITEM_SLOT_EYES,
		"ears" = ITEM_SLOT_EARS,
		"wear_id" = ITEM_SLOT_ID,
		"s_store" = ITEM_SLOT_SUITSTORE,
	)

	var/datum/dna/chosen_dna = chosen_prof.dna
	user.real_name = chosen_prof.name
	user.underwear = chosen_prof.underwear
	user.undershirt = chosen_prof.undershirt
	user.socks = chosen_prof.socks

	chosen_dna.transfer_identity(user, 1)

	///Bodypart data hack. Will rewrite when I rewrite changelings soon-ish
	for(var/obj/item/bodypart/BP as() in user.bodyparts)
		if(IS_ORGANIC_LIMB(BP))
			BP.update_limb(is_creating = TRUE)

	user.updateappearance(mutcolor_update=1)
	user.domutcheck()

	//vars hackery. not pretty, but better than the alternative.
	for(var/slot in slot2type)
		if(istype(user.vars[slot], slot2type[slot]) && !(chosen_prof.exists_list[slot])) //remove unnecessary flesh items
			qdel(user.vars[slot])
			continue

		if((user.vars[slot] && !istype(user.vars[slot], slot2type[slot])) || !(chosen_prof.exists_list[slot]))
			continue

		if(istype(user.vars[slot], slot2type[slot]) && slot == "wear_id") //always remove old flesh IDs, so they get properly updated
			qdel(user.vars[slot])

		var/obj/item/C
		var/equip = 0
		if(!user.vars[slot])
			var/thetype = slot2type[slot]
			equip = 1
			C = new thetype(user)

		else if(istype(user.vars[slot], slot2type[slot]))
			C = user.vars[slot]

		C.appearance = chosen_prof.appearance_list[slot]
		C.name = chosen_prof.name_list[slot]
		C.flags_cover = chosen_prof.flags_cover_list[slot]
		C.lefthand_file = chosen_prof.lefthand_file_list[slot]
		C.righthand_file = chosen_prof.righthand_file_list[slot]
		C.item_state = chosen_prof.item_state_list[slot]
		C.worn_icon = chosen_prof.worn_icon_list[slot]
		C.worn_icon_state = chosen_prof.worn_icon_state_list[slot]

		if(istype(C, /obj/item/card/id/changeling) && chosen_prof.id_job_name)
			var/obj/item/card/id/changeling/flesh_id = C
			flesh_id.assignment = chosen_prof.id_job_name
			flesh_id.hud_state = chosen_prof.id_hud_state

		if(equip)
			user.equip_to_slot_or_del(C, slot2slot[slot])
			if(!QDELETED(C))
				ADD_TRAIT(C, TRAIT_NODROP, CHANGELING_TRAIT)

	user.regenerate_icons()


/datum/game_mode/changeling/generate_credit_text()
	var/list/round_credits = list()
	var/len_before_addition

	round_credits += "<center><h1>The Slippery Changelings:</h1>"
	len_before_addition = round_credits.len
	for(var/datum/mind/M in changelings)
		var/datum/antagonist/changeling/cling = M.has_antag_datum(/datum/antagonist/changeling)
		if(cling)
			round_credits += "<center><h2>[cling.changelingID] in the body of [M.name]</h2>"
	if(len_before_addition == round_credits.len)
		round_credits += list("<center><h2>Uh oh, we lost track of the shape shifters!</h2>", "<center><h2>Nobody move!</h2>")
	round_credits += "<br>"

	round_credits += ..()
	return round_credits
