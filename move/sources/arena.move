module challenge::arena;

use challenge::hero::{Self, Hero};
use sui::event;
use sui::transfer::public_transfer;
use sui::object;
use sui::tx_context::TxContext;
use sui::object::UID;

// ========= STRUCTS =========

public struct Arena has key, store {
    id: UID,
    warrior: Hero,
    owner: address,
}

// ========= EVENTS =========

public struct ArenaCreated has copy, drop {
    arena_id: ID,
    timestamp: u64,
}

public struct ArenaCompleted has copy, drop {
    winner_hero_id: ID,
    loser_hero_id: ID,
    timestamp: u64,
}

// ========= FUNCTIONS =========

public fun create_arena(hero: Hero, ctx: &mut TxContext) {
    let arena_id = object::new(ctx);
    let arena = Arena {
        id: arena_id,
        warrior: hero,
        owner: ctx.sender(),
    };
    
    // IMPORTANT: Extract the ID before transferring ownership
    let arena_id = object::id(&arena);
    
    // Emit ArenaCreated event
    event::emit(ArenaCreated {
        arena_id,
        timestamp: ctx.epoch_timestamp_ms(),
    });
    transfer::share_object(arena);
    // TODO: Create an arena object
        // Hints:
        // Use object::new(ctx) for unique ID
        // Set warrior field to the hero parameter
        // Set owner to ctx.sender()
    // TODO: Emit ArenaCreated event with arena ID and timestamp (Don't forget to use ctx.epoch_timestamp_ms(), object::id(&arena))
    // TODO: Use transfer::share_object() to make it publicly tradeable
}

#[allow(lint(self_transfer))]
public fun battle(mut hero: Hero, mut arena: Arena, ctx: &mut TxContext) {
    // Calculate hero powers BEFORE consuming the values
    let hero_power = hero.hero_power();
    let arena_warrior_power = arena.warrior.hero_power();
    
    // Get IDs BEFORE transferring (moving) the objects
    let hero_id = object::id(&hero);
    let warrior_id = object::id(&arena.warrior);
    
    // Destructure arena to get id, warrior, and owner
    let Arena { id, mut warrior, owner } = arena;
    
    // Battle logic: compare powers and transfer heroes
    if (hero_power > arena_warrior_power) {
        // Hero wins: award XP to hero and transfer both heroes to challenger
        hero::award_xp(&mut hero, 100);
        transfer::public_transfer(warrior, ctx.sender());
        transfer::public_transfer(hero, ctx.sender());
        event::emit(ArenaCompleted {
            winner_hero_id: hero_id,
            loser_hero_id: warrior_id,
            timestamp: ctx.epoch_timestamp_ms(),
        });
    } else {
        // Warrior wins: award XP to warrior and transfer both heroes to arena owner
        hero::award_xp(&mut warrior, 100);
        transfer::public_transfer(hero, owner);
        transfer::public_transfer(warrior, owner);
        event::emit(ArenaCompleted {
            winner_hero_id: warrior_id,
            loser_hero_id: hero_id,
            timestamp: ctx.epoch_timestamp_ms(),
        });
    };
    
    // Delete the arena ID since the arena is consumed
    object::delete(id);
}

