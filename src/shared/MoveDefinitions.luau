-- Prototype-only tuning values. Replace with measured, playtested data.
export type Move = {
    id: string,
    startup: number,
    active: number,
    recovery: number,
    staminaCost: number,
    range: number,
    target: string,
}
local Moves: {[string]: Move} = {
    jab = {id="jab", startup=0.11, active=0.07, recovery=0.20, staminaCost=5, range=4.5, target="head"},
    cross = {id="cross", startup=0.17, active=0.08, recovery=0.28, staminaCost=8, range=4.7, target="head"},
    leadHook = {id="leadHook", startup=0.19, active=0.09, recovery=0.31, staminaCost=9, range=3.5, target="head"},
    rearUppercut = {id="rearUppercut", startup=0.21, active=0.09, recovery=0.35, staminaCost=10, range=2.8, target="head"},
}
return table.freeze(Moves)
