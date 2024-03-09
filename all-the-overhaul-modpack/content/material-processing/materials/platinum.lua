local Recipe = atom.util.Recipe

local config = atom.processing.util.prepareConfig({
    name = "platinum",
    order = "u",
    itemNames = {
        ore = "raw-rare-metals",
        dust = "platinum-powder",
        ingot = "platinum-ingot",
        enriched = "atom-platinum-enriched"
    },
    icons = {
        dust = { icon = "__bzgold__/graphics/icons/platinum-powder.png", icon_size = 64 },
        "ingot", "enriched"
    },
    additionalResults = {
        dustToIngot = {
            { name = "sulfur", amount = 1, probability = 0.4 }
        },
        dustToEnriched = {
            { name = "sulfur", amount = 1, probability = 0.16 }
        }
    },
    unlockedBy = {
        oreToDust = "platinum-processing",
        dustToIngot = "platinum-processing"
    }
})

local create = atom.processing.create(config)

-- Raw rare metals to platinum powder
local oreToDustRecipe = Recipe({
    type = "recipe",
    name = "atom-" .. config.name .. "-dust",
    icons = {
        config.icons.dust,
        atom.util.icon.createSmallIcon(atom.processing.materials.rareMetals.icons.ore),
    },
    category = "core-fragment-processing",
    energy_required = 9.6,
    ingredients = {
        { config.itemNames.ore, 6 },
        { type = "fluid", name = "aqua-regia", amount = 3 }
    },
    results = {
        { name = config.itemNames.dust, amount = 6 },
        data.raw.fluid["depleted-acid"] and { type = "fluid", name = "depleted-acid", amount = 3 } or nil
    },
    main_product = config.itemNames.dust,
    enabled = false
})
oreToDustRecipe.unlockedByTechnology(config.unlockedBy.oreToDust)

local dustToIngotRecipe = create.dustToIngotRecipe()
dustToIngotRecipe.prototype.results[2].amount = 6

local dustToEnrichedRecipe = create.dustToEnrichedRecipe()
dustToEnrichedRecipe.prototype.ingredients[1].amount = 10

local enrichedToIngotRecipe = create.enrichedToIngotRecipe()
enrichedToIngotRecipe.prototype.results[1].amount = 6

atom.util.applyAll({
    oreToDustRecipe,
    dustToIngotRecipe,
    dustToEnrichedRecipe,
    enrichedToIngotRecipe,
    create.item("enriched")
})

atom.processing.util.finalizeConfig(config)

atom.processing.materials.platinum = config