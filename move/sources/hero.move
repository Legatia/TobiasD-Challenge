module challenge::hero;

use std::string::String;

// ========= STRUCTS ========= 

// ========= STRUCTS =========
public struct Hero has key, store {
    id: UID,
    name: String,
    image_url: String,
    power: u64,
    xp: u64,
    level: u64,
}

public struct HeroMetadata has key, store {
    id: UID,
    timestamp: u64,
}

// ========= CONSTANTS =========

const XP_PER_LEVEL: u64 = 100;
const POWER_PER_LEVEL: u64 = 10;
const XP_REWARD_PER_BATTLE: u64 = 100;

// ========= ERRORS =========

const EInsufficientXP: u64 = 1;


// ========= FUNCTIONS =========

#[allow(lint(self_transfer))]
public fun create_hero(name: String, image_url: String, power: u64, ctx: &mut TxContext) {
    let hero_id = object::new(ctx);
    let hero = Hero {
        id: hero_id,
        name: name,
        image_url: image_url,
        power: power,
        xp: 0,
        level: 1,
    }; 
    transfer::transfer(hero, ctx.sender());
    let metadata = HeroMetadata {
        id: object::new(ctx),
        timestamp: ctx.epoch_timestamp_ms(),
    };
    transfer::freeze_object(metadata);
    // TODO: Create a new Hero struct with the given parameters
        // Hints:
        // Use object::new(ctx) to create a unique ID
        // Set name, image_url, and power fields
    // TODO: Transfer the hero to the transaction sender
    // TODO: Create HeroMetadata and freeze it for tracking
        // Hints:
        // Use ctx.epoch_timestamp_ms() for timestamp
    //TODO: Use transfer::freeze_object() to make metadata immutable
}

// ========= LEVELING FUNCTIONS =========

/// Award XP to a hero (called by arena module after battle)
public(package) fun award_xp(hero: &mut Hero, xp_amount: u64) {
    hero.xp = hero.xp + xp_amount;
}

/// Award standard battle XP to a hero (uses constant)
public(package) fun award_battle_xp(hero: &mut Hero) {
    award_xp(hero, XP_REWARD_PER_BATTLE);
}

/// Level up a hero when they have enough XP
public fun level_up_hero(hero: &mut Hero) {
    // Check if hero has enough XP to level up
    assert!(hero.xp >= XP_PER_LEVEL, EInsufficientXP);
    
    // Deduct XP and increase level
    hero.xp = hero.xp - XP_PER_LEVEL;
    hero.level = hero.level + 1;
    
    // Increase power
    hero.power = hero.power + POWER_PER_LEVEL;
}


// ========= GETTER FUNCTIONS =========

public fun hero_power(hero: &Hero): u64 {
    hero.power
}

public fun hero_xp(hero: &Hero): u64 {
    hero.xp
}

public fun hero_level(hero: &Hero): u64 {
    hero.level
}


#[test_only]
public fun hero_name(hero: &Hero): String {
    hero.name
}

#[test_only]
public fun hero_image_url(hero: &Hero): String {
    hero.image_url
}

#[test_only]
public fun hero_id(hero: &Hero): ID {
    object::id(hero)
}

