#define SCREWDRIVER_TWIST "DHG"
#define INSULATED_PUNCH "HDH"
#define TUNNEL_KICK "DG"
#define MAINTENANCE_PROD "HD"

/datum/martial_art/maintfu
	name = "Maints-Fu (Maintenance not required)"
	id = MARTIALART_MAINTFU
	var/maints_only = FALSE

/datum/martial_art/maintfu/maints
	name = "Maints-Fu"
	maints_only = TRUE

/datum/martial_art/maintfu/can_use(mob/living/carbon/human/H)
	var/area/A = get_area(H)
	if(maints_only && !(istype(A, /area/maintenance)))
		return FALSE
	return ..()

/datum/martial_art/maintfu/proc/check_streak(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(findtext(streak,SCREWDRIVER_TWIST))
		streak = ""
		screwTwist(A,D)
		return TRUE
	if(findtext(streak,INSULATED_PUNCH))
		streak = ""
		insulatedPunch(A,D)
		return TRUE
	if(findtext(streak,TUNNEL_KICK))
		streak = ""
		tunnelKick(A,D)
		return TRUE
	if(findtext(streak,MAINTENANCE_PROD))
		streak = ""
		maintProd(A,D)
		return TRUE
	return FALSE

/datum/martial_art/maintfu/proc/screwTwist(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	log_combat(A, D, "screwdriver twisted (Maints-Fu)", name)
	D.visible_message("<span class='danger'>[A] sticks their finger in [D]'s eyes!</span>", \
					"<span class='userdanger'>Your eyes are jabbed by [A] finger!</span>", "<span class='hear'>You hear a screwdriver hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You stick your fingers in [D]'s eyes!</span>")
	D.adjustOrganLoss(ORGAN_SLOT_EYES, 70)
	D.apply_damage(10, BRUTE)
	playsound(get_turf(A), 'sound/weapons/slice.ogg', 50, 1, -1)
	return TRUE

/datum/martial_art/maintfu/proc/insulatedPunch(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	log_combat(A, D, "insulated punch's (Maints-Fu)", name)
	D.visible_message("<span class='danger'>[A] violently punches in [D]'s chest, shocking them!</span>", \
					"<span class='userdanger'>You're punched in the chest by [A] violently!!</span>", "<span class='hear'>You hear [D] get shocked!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You punch [D] in the chest violently, shocking them!</span>")
	D.apply_damage(17, BURN)
	D.electrocute_act(15,"hands", flags = SHOCK_NOGLOVES | SHOCK_NOSTUN)
	playsound(get_turf(A), 'sound/weapons/taser.ogg', 50, 1, -1)
	return TRUE


/datum/martial_art/maintfu/proc/tunnelKick(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	log_combat(A, D, "tunnel kicks (Maints-Fu)", name)
	D.visible_message("<span class='danger'>[A] kicks [D]'s hip, causing them to fall</span>", \
					"<span class='userdanger'>Your hip is kicked by [A], causing you to faul over!!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You stick your fingers in [D]'s eyes!</span>")
	D.apply_damage(15, BRUTE)
	D.Knockdown(60)
	playsound(get_turf(A), 'sound/weapons/cqchit1.ogg', 50, 1, -1)
	return TRUE

/datum/martial_art/maintfu/proc/maintProd(mob/living/carbon/human/A, mob/living/carbon/human/D)
	if(!can_use(A))
		return FALSE
	log_combat(A, D, "maintenance prod's (Maints-Fu)", name)
	D.visible_message("<span class='danger'>[A] jabs [D], stunning them in shock!</span>", \
					"<span class='userdanger'>Your hip is kicked by [A], causing you to faul over!</span>", "<span class='hear'>You hear a sickening sound of flesh hitting flesh!</span>", COMBAT_MESSAGE_RANGE, A)
	to_chat(A, "<span class='danger'>You jab [D]'s side, calling them to fall!</span>")
	D.apply_damage(90, STAMINA)
	D.Knockdown(60)
	playsound(get_turf(A), 'sound/weapons/cqchit2.ogg', 50, 1, -1)
	return TRUE

#undef SCREWDRIVER_TWIST
#undef INSULATED_PUNCH
#undef TUNNEL_KICK
#undef MAINTENANCE_PROD




