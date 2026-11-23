local Config = {
    MaxStamina = 100,
    StaminaRegenPerSecond = 13,
    GuardWalkSpeed = 9,
    WalkSpeed = 14,
    MaxRequestAge = 0.45,
    MaxRangeStuds = 6,
    FacingDotMinimum = 0.25,
    SlipDuration = 0.33,
    SlipCooldown = 0.45,
    GuardDamageMultiplier = 0.2,
    SlipDamageMultiplier = 0.0,
    BaseDamage = {jab = 5, cross = 9, leadHook = 10, rearUppercut = 11},
}
return table.freeze(Config)
