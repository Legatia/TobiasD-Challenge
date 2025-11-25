import { Transaction } from "@mysten/sui/transactions";

export const levelUpHero = (packageId: string, heroId: string) => {
    const tx = new Transaction();

    // Add moveCall to level up a hero
    // Function: `${packageId}::hero::level_up_hero`
    // Arguments: heroId (object)
    tx.moveCall({
        target: `${packageId}::hero::level_up_hero`,
        arguments: [tx.object(heroId)],
    });

    return tx;
};
