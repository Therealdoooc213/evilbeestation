/*
Synthetic
*/
/datum/job/assistant
	title = JOB_NAME_ASSISTANT
	description = "Help out around the station or ask the Head of Personnel for an assignment. As the lowest-level position, expect to be treated like an intern most of the time."
	department_for_prefs = DEPT_NAME_SILICON
	supervisors = "The AI, everyone."
	faction = "Station"
	total_positions = 1
	spawn_positions = 5
	selection_color = "#dddddd"
	antag_rep = 7

	outfit = /datum/outfit/job/assistant

	base_access = list()	//See /datum/job/assistant/get_access()
	extra_access = list()	//See /datum/job/assistant/get_access()

	departments = DEPT_BITFLAG_SILICON
	bank_account_department = NONE // nothing is free for them
	payment_per_department = list(ACCOUNT_CIV_ID = PAYCHECK_ASSISTANT) // Get a job. Job reassignment changes your paycheck now. Get over it.

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	rpg_title = "Mechanical Monstrosity"

	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman
	)

/datum/job/synthetic/get_access()
	return get_all_accesses()

/datum/outfit/job/synthetic
	name = JOB_NAME_SYNTHETIC
	jobtype = /datum/job/assistant
	belt = /obj/item/modular_computer/tablet/pda/assistant

/datum/outfit/job/asynthetic/pre_equip(mob/living/carbon/human/H)
	..()
	if (CONFIG_GET(flag/grey_assistants))
		give_grey_suit(H)
	else
		if(H.jumpsuit_style == PREF_SUIT)
			uniform = /obj/item/clothing/under/color/random
		else
			uniform = /obj/item/clothing/under/color/jumpskirt/random

/datum/outfit/job/synthetic/proc/give_grey_suit(mob/living/carbon/human/target)
	if (target.jumpsuit_style == PREF_SUIT)
		uniform = /obj/item/clothing/under/misc/colonist
	else
		NULL

/datum/outfit/job/synthetic/consistent
	name = "Synthetic"

/datum/outfit/job/synthetic/consistent/pre_equip(mob/living/carbon/human/H)
	..()
	give_grey_suit(H)

/datum/outfit/job/synthetic/consistent/post_equip(mob/living/carbon/human/H, visualsOnly)
	..()

	// This outfit is used by the assets SS, which is ran before the atoms SS
	if (SSatoms.initialized == INITIALIZATION_INSSATOMS)
		H.w_uniform?.update_greyscale()
		H.update_inv_w_uniform()

/datum/job/synthetic/after_spawn(/mob/living/carbon/human/species/synthetic, mob/M, latejoin = FALSE, client/preference_source, on_dummy = FALSE)
	if(!M.client || on_dummy)
		return
	R.updatename(M.client)
