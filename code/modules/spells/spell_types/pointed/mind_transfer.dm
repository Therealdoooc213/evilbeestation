/datum/action/spell/pointed/mind_transfer
	name = "Mind Swap"
	desc = "This spell allows the user to switch bodies with a target next to him."
	button_icon_state = "mindswap"
	ranged_mousepointer = 'icons/effects/mouse_pointers/mindswap_target.dmi'

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank =  10 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC|SPELL_REQUIRES_MIND|SPELL_CASTABLE_AS_BRAIN
	antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_MIND

	invocation = "GIN'YU CAPAN"
	invocation_type = INVOCATION_WHISPER

	active_msg = "You prepare to swap minds with a target..."
	deactive_msg = "You dispel mind swap."
	cast_range = 1

	/// If TRUE, we cannot mindswap into mobs with minds if they do not currently have a key / player.
	var/target_requires_key = TRUE
	/// If TRUE, we cannot mindswap into people without a mind.
	/// You may be wondering "What's the point of mindswap if the target has no mind"?
	/// Primarily for debugging - targets hit with this set to FALSE will init a mind, then do the swap.
	var/target_requires_mind = TRUE
	/// For how long is the caster stunned for after the spell
	var/unconscious_amount_caster = 40 SECONDS
	/// For how long is the victim stunned for after the spell
	var/unconscious_amount_victim = 40 SECONDS
	/// List of mobs we cannot mindswap into.
	var/static/list/mob/living/blacklisted_mobs = typecacheof(list(
		/mob/living/brain,
		/mob/living/silicon/pai,
		/mob/living/simple_animal/hostile/imp/slaughter,
		/mob/living/simple_animal/hostile/megafauna,
	))

/datum/action/spell/pointed/mind_transfer/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(owner))
		return FALSE
	if(owner.suiciding)
		if(feedback)
			to_chat(owner, "<span class='warning'>You're killing yourself! You can't concentrate enough to do this!</span>")
		return FALSE
	return TRUE

/datum/action/spell/pointed/mind_transfer/is_valid_spell(mob/user, atom/target)
	. = ..()
	if(!.)
		return FALSE

	if (target == user)
		to_chat(user, "<span class='warning'>You cannot swap mind with yourself!</span>")
		return FALSE
	if(!isliving(target))
		to_chat(owner, "<span class='warning'>You can only swap minds with living beings!</span>")
		return FALSE
	if(is_type_in_typecache(target, blacklisted_mobs))
		to_chat(owner, "<span class='warning'>This creature is too [pick("powerful", "strange", "arcane", "obscene")] to control!</span>")
		return FALSE
	if(isholopara(target))
		var/mob/living/simple_animal/hostile/holoparasite/stand = target
		if(stand.summoner && stand.summoner == owner)
			to_chat(owner, "<span class='warning'>Swapping minds with your own guardian would just put you back into your own head!</span>")
			return FALSE
	var/mob/living/living_target = target
	if(living_target.stat == DEAD)
		to_chat(owner, "<span class='warning'>You don't particularly want to be dead!</span>")
		return FALSE
	if(!living_target.mind && target_requires_mind)
		to_chat(owner, "<span class='warning'>[living_target.p_theyve(TRUE)] doesn't appear to have a mind to swap into!</span>")
		return FALSE
	if(!living_target.key && target_requires_key)
		to_chat(owner, "<span class='warning'>[living_target.p_theyve(TRUE)] appear[living_target.p_s()] to be catatonic! \
			Not even magic can affect [living_target.p_their()] vacant mind.</span>")
		return FALSE

	return TRUE

/datum/action/spell/pointed/mind_transfer/on_cast(mob/living/user, atom/target)
	. = ..()
	swap_minds(user, target)

/datum/action/spell/pointed/mind_transfer/proc/swap_minds(mob/living/caster, mob/living/cast_on)

	var/mob/living/to_swap = cast_on
	if(isholopara(cast_on))
		var/mob/living/simple_animal/hostile/holoparasite/stand = cast_on
		if(stand.summoner)
			to_swap = stand.summoner

	// Gives the target a mind if we don't require one and they don't have one
	if(!to_swap.mind && !target_requires_mind)
		to_swap.mind_initialize()

	var/datum/mind/mind_to_swap = to_swap.mind
	if(to_swap.can_block_magic(antimagic_flags) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/wizard) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/cult) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/changeling) \
		|| mind_to_swap.has_antag_datum(/datum/antagonist/rev) \
		|| mind_to_swap.key?[1] == "@" \
	)
		to_chat(caster, ("<span class='warning'>[to_swap.p_their(TRUE)] mind is resisting your spell!</span>"))
		return FALSE

	// MIND TRANSFER BEGIN

	var/datum/mind/caster_mind = caster.mind
	var/datum/mind/to_swap_mind = to_swap.mind

	var/to_swap_key = to_swap.key

	caster_mind.transfer_to(to_swap)
	to_swap_mind.transfer_to(caster)

	// Just in case the swappee's key wasn't grabbed by transfer_to...
	if(to_swap_key)
		caster.key = to_swap_key
	// MIND TRANSFER END

	// Now we knock both mobs out for a time.
	caster.Unconscious(unconscious_amount_caster)
	to_swap.Unconscious(unconscious_amount_victim)

	// Only the caster and victim hear the sounds,
	// that way no one knows for sure if the swap happened
	SEND_SOUND(caster, sound('sound/magic/mandswap.ogg'))
	SEND_SOUND(to_swap, sound('sound/magic/mandswap.ogg'))

	return TRUE
