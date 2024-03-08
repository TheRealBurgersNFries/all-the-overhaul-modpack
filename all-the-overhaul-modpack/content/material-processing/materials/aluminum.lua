local config = atom.processing.util.prepareConfig({
    name = "aluminum",
    order = "b",
    enableAtStart = true,
    itemNames = {
        ore = "aluminum-ore",
        plate = "aluminum-plate",
        dust = "atom-aluminum-dust",
        ingot = "aluminum-ingot",
        molten = "molten-aluminum",
        enriched = "enriched-aluminum",
        pure = "el_materials_pure_aluminum",
        pellets = "atom-aluminum-pellets",
        alumina = "alumina"
    },
    icons = {
        ore = { icon = "__bzaluminum__/graphics/icons/aluminum-ore.png", icon_size = 64, icon_mipmaps = 3 },
        "pure", "plate", "dust", "ingot", "molten", "enriched", "pellets",
        alumina = { icon = "__bzaluminum__/graphics/icons/alumina.png", icon_size = 128 }
    },
    additionalResults = {
        dustToIngot = {
            { name = "alumina", amount = 1, probability = 0.26 }
        },
        dustToEnriched = {
            { name = "alumina", amount = 1, probability = 0.26 }
        },
        dustToPure = {
            { name = "alumina", amount = 1, probability = 0.26 }
        }
    },
})

local oreToAluminaRecipe = {
    type = "recipe",
    name = "atom-alumina-ore",
    icons = {
        config.icons.alumina,
        atom.util.icon.createSmallIcon(config.icons.ore),
    },
    category = "smelting",
    energy_required = 3.2,
    ingredients = {
        { config.itemNames.ore, 2 }
    },
    results = {
        { name = config.itemNames.alumina, amount = 1 },
        { name = "silica", amount = 1, probability = 0.05 }
    },
    main_product = config.itemNames.alumina,
    enabled = config.enableAtStart or false
}

local aluminaToPlateRecipe = {
    type = "recipe",
    name = "atom-" .. config.name .. "-plate",
    icons = {
        config.icons.plate,
        atom.util.icon.createSmallIcon(config.icons.alumina),
    },
    category = "smelting",
    energy_required = 19.2,
    ingredients = {
        { config.itemNames.alumina, 6 }
    },
    results = { { name = config.itemNames.plate, amount = 6 } },
    enabled = config.enableAtStart or false
}


local dustToAluminaRecipe = {
    type = "recipe",
    name = "atom-alumina-dust",
    icons = {
        config.icons.alumina,
        atom.util.icon.createSmallIcon(config.icons.dust),
    },
    category = "smelting",
    energy_required = 3.2,
    ingredients = {
        { config.itemNames.dust, 3 }
    },
    results = {
        { name = config.itemNames.alumina, amount = 1 },
        { name = "silica", amount = 1, probability = 0.0167 }
    },
    main_product = config.itemNames.alumina,
    enabled = false
}

local create = atom.processing.create(config)

data:extend({
    oreToAluminaRecipe,
    aluminaToPlateRecipe,
    dustToAluminaRecipe,
    create.oreToDustRecipe(),
    create.dustToIngotRecipe(),
    create.ingotToPlateRecipe(),
    create.ingotToMoltenRecipe(),
    create.moltenToPlateRecipe(),
    create.dustToEnrichedRecipe(),
    create.enrichedToIngotRecipe(),
    create.dustToPureRecipe(),
    create.pureToEnrichedRecipe(),
    create.enrichedToPelletsRecipe(),
    create.pelletsToIngotRecipe(),
    create.item("pellets"),
    create.item("dust")
})

atom.util.recipe.allowProductivity(aluminaToPlateRecipe.name)
atom.util.recipe.unlockedByTechnology(dustToAluminaRecipe.name, "5d-masher-1")

atom.processing.util.finalizeConfig(config)

atom.processing.materials.aluminum = config