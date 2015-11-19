This is a combat system for a "Board Game Online" variant game.

# Statistics

Every creature and player has the following stats:

* Health - When you hit 0, you die! Death lasts 3 rounds for players.
* Attack - Added to your attack roll.
* Defense - Bonus to armor class (10 + Defense)
* Damage - The amount of damage a successful attack does. Is broken down by damage type. (E.g., 3 swords to represent 3 physical damage)

The default stats of a player without any items/boons/curses/etc. is:

Health 10 / Attack 0 / Defense 0 / Damage 2 Physical

# Damage Types

(These types *could* change)

* Physical (Sword icon)
* Mental (Brain icon)
* Fire (Flame icon)
* Wind (Swirl icon)
* Earth (Rock icon)
* Water (Water drop icon)

These are hooks for status effects. E.g., a `Nul-Fire` ability would make the creature or player immune to fire damage.

# Encounters

After rolling movement, the player (transparantly) draws an event type.
A certain percentage will be encounter.

Upon an encounter, the game looks at the player's equipment and determines
the rank of the player, picking an encounter that is at that rank, or rarely
one higher.

The player sees the stats for the enemy, and has three default options,
attack, defend, and flee.

Whichever option the player picks, the enemy's
option is resolved at the same time. So in the most common case where
both the enemy and the player attack, both attacks happen at the same
time possibly causing a draw due to both being dead.

## Attack

The player rolls attack (3d6 + player attack vs 10 + creature defense).
If the roll succeeds, the player deals damage to the creature.

## Defend

The player gains +3 defense for the current turn and +2 attack for the
next turn.

## Flee

The player gains +1 defense. The encounter ends.

# Victory Bonus

The player gains an item of equal or higher rank than the creature defeated.
Most often, this is going to be equipment.

Perhaps some health should regenerate too?

# Example

Using slimes because why not?

## Fire Slime

```
The player has 10 health, 0 attack, 0 defense, and deals 2 physical damage.
The player is rank 1.
```

```
The player encounters a fire slime. It has 4 health, 0 attack, 0 defense, and 2 fire damage.
It is a Rank 1 encounter.
```

### Battle Round 1

```
The player attacks. The fire slime attacks.
The player's attack hits (roll: 4, 4, 2). The fire slime's attack misses (roll: 2, 5, 1).
```

```
The player deals 2 damage to the fire slime.
```

### Battle Round 2

```
The player attacks. The fire slime attacks.
The player's attack hits. The fire slime's attack hits.
```

```
The player deals 2 damage to the fire slime.
The fire slime deals 2 damage to the player.
The fire slime dies.
```

### Victory

```
The player gains a rank 2 item.
```

## Fast Slime

```
The player has 4 health, 0 attack, 0 defense, and deals 2 physical damage.
The player is rank 1.
```

```
The player encounters a fast slime. It has 4 health, 0 attack, 0 defense, and 2 physical damage.
A fast slime has the `first strike` ability.
It is a Rank 2 encounter.
This is a dangerous encounter.
```

`first strike`: When attacking, if you defeat the opponent, it's action for the battle round is nullified.
You'll see how this works in the second battle round.

### Battle Round 1

```
The player attacks. The fire slime attacks.
The player's attack hits. The fire slime's attack hits.
```

```
The player deals 2 damage to the fire slime.
The fast slime deals 2 damage to the player.
```

### Battle Round 2

```
The player attacks. The fire slime attacks.
The player's attack hits. The fire slime's attack hits.
```

```
The fast slime deals 2 damage to the player.
The player dies.
(Player's attack canceled due to fast slime's `first strike`)
```