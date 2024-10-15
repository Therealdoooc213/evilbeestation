/datum/species/synth
	name = "\improper Synthetic" //"I cant lie to you about your chances, but you have my sympathies."
	id = SPECIES_SYNTHETIC
	default_color = "#fce9fb"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	inherent_traits = list(TRAIT_BLOOD_COOLANT,TRAIT_NOBREATH,TRAIT_RADIMMUNE,TRAIT_EASYDISMEMBER,TRAIT_XENO_IMMUNE, TRAIT_TOXIMMUNE)
	mutanttongue = /obj/item/organ/tongue/robot
	mutantheart = /obj/item/organ/heart/cybernetic/ipc
	species_language_holder = /datum/language_holder/synth

	use_skintones = 1
	skinned_type = /obj/item/stack/sheet/iron{amount = 5}
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP | SLIME_EXTRACT

	burnmod = 2.3
	heatmod = 2
	brutemod = 1
	clonemod = 0
	staminamod = 0.8
	siemens_coeff = 1.5
	deathsound = "sound/voice/borg_deathsound.ogg"
	reagent_tag = PROCESS_SYNTHETIC
	species_bitflags = NOT_TRANSMORPHIC

	exotic_blood = /datum/reagent/oil
	blood_color = "#fcdddd"
	bleed_effect = /datum/status_effect/bleeding/robotic


/datum/species/human/qualifies_for_rank(rank, list/features)
	return TRUE	//Pure humans are always allowed in all roles.

/datum/species/human/get_laugh_sound(mob/living/carbon/user)
	return user.gender == FEMALE ? 'sound/voice/human/womanlaugh.ogg' : pick('sound/voice/human/manlaugh1.ogg', 'sound/voice/human/manlaugh2.ogg')

/datum/species/human/get_scream_sound(mob/living/carbon/user)
	return user.gender == FEMALE ? pick(
		'sound/voice/human/femalescream_1.ogg',
		'sound/voice/human/femalescream_2.ogg',
		'sound/voice/human/femalescream_3.ogg',
		'sound/voice/human/femalescream_4.ogg',
		) : pick(
		'sound/voice/human/malescream_1.ogg',
		'sound/voice/human/malescream_2.ogg',
		'sound/voice/human/malescream_3.ogg',
		'sound/voice/human/malescream_4.ogg',
		'sound/voice/human/malescream_5.ogg',
		)

/datum/species/human/get_cough_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_COUGH_SOUND(user)

/datum/species/human/get_gasp_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_GASP_SOUND(user)

/datum/species/human/get_sigh_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SIGH_SOUND(user)

/datum/species/human/get_sneeze_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNEEZE_SOUND(user)

/datum/species/human/get_sniff_sound(mob/living/carbon/user)
	return SPECIES_DEFAULT_SNIFF_SOUND(user)

/datum/species/human/prepare_human_for_preview(mob/living/carbon/human/human)
	human.hair_style = "Business Hair"
	human.hair_color = "b96" // brown
	human.update_hair()

/datum/species/human/get_species_description()
	return "Synthetics are a artificially produced species of half human half robot people \
		Their 'kind' are widely looked down apon across the universe for being monsters."

/datum/species/human/get_species_lore()
	return list(
		"These primate-descended creatures, originating from the mostly harmless Earth, \
		have long-since outgrown their home and semi-benign designation. \
		The space age has taken humans out of their solar system and into the galaxy-at-large."
	)

/datum/species/synthetic/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "robot",
		SPECIES_PERK_NAME = "Asimov Superiority",
		SPECIES_PERK_DESC = "The AI and their cyborgs are often (but not always) subservient only \
			to humans. As a human, silicons are required to both protect and obey you under the Asimov lawset.",
	),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "magnet",
			SPECIES_PERK_NAME = "EMP Vulnerable",
			SPECIES_PERK_DESC = "Synthetic organs are cybernetic, and thus susceptible to electromagnetic interference. Getting hit by an EMP may stop your heart.",
		),
	)

	if(CONFIG_GET(flag/enforce_human_authority))
		to_add += list(list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bullhorn",
			SPECIES_PERK_NAME = "Chain of Command",
			SPECIES_PERK_DESC = "Nanotrasen only recognizes humans for command roles, such as Captain.",
		))

	return to_add
