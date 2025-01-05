/datum/job/liason
	title = JOB_NAME_LIASON
	description = "Get your radio stolen by a assistant. Relay information to Central Command via fax, get your fax blown up by Central Command for abusing it."
	supervisors = "the captain, central command, space law."
	bank_account_department = ACCOUNT_VIP_BITFLAG
	exp_requirements = 1200
	exp_type_department = EXP_TYPE_COMMAND
	payment_per_department = list(ACCOUNT_VIP_ID = PAYCHECK_COMMAND_DEPT) //I'm sure Burke wasn't paid that much, considering at how shit he was at his job.
	department_for_prefs = DEPT_NAME_VIP
	departments = DEPT_BITFLAG_CENTCOM
	selection_color = "#10bd01d2"

	outfit = /datum/outfit/job/gimmick/liason
	base_access = list(ACCESS_HEADS, ACCESS_CENT_LIVING) //This access isn't used anywhere else (to my knowledge), so it should be fine.
	species_outfits = list(
		SPECIES_PLASMAMAN = /datum/outfit/plasmaman/official
	)
	rpg_title = "Town Crier"
	display_order = JOB_DISPLAY_ORDER_LIASON

/datum/outfit/job/gimmick/liason
	name = JOB_NAME_LIASON
	jobtype = /datum/job/gimmick/liason
	id = /obj/item/card/id/centcom
	belt = /obj/item/clipboard
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	l_pocket = /obj/item/modular_computer/tablet/pda/heads
	ears = /obj/item/radio/headset/headset_cent/liason
	uniform = /obj/item/clothing/under/rank/centcom/officer
	shoes = /obj/item/clothing/shoes/laceup
