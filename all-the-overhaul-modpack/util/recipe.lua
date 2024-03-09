local productivityModules = {}
for _, module in pairs(data.raw["module"]) do
    if string.find(module.name, "productivity", 1, true) then
        table.insert(productivityModules, module)
    end
end

atom.util.recipe = {
    -- Removes a recipe by name together with all its dependencies
    -- @param name string The name of the recipe
    removeByName = function(name)
        data.raw.recipe[name] = nil

        for _, module in pairs(data.raw.module) do
            if (module.limitation) then
                for key, value in pairs(module.limitation) do
                    if value == name then
                        module.limitation[key] = nil
                    end
                end
            end
        end
        for _, technology in pairs(data.raw.technology) do
            if (technology.effects) then
                for i, value in pairs(technology.effects) do
                    if value.recipe == name then
                        technology.effects[i] = nil
                    end
                end
            end
        end
    end,

    -- Removes all recipes that match a pattern together with all their dependencies
    -- @param pattern string The pattern to match (see https://www.lua.org/manual/5.2/manual.html#6.4.1)
    -- @param exceptions? table A list of recipes to keep
    removeByNamePattern = function(pattern, exceptions)
        exceptions = exceptions or {}
        for key, _ in pairs(data.raw.recipe) do
            if string.find(key, pattern) ~= nil and not table.contains(exceptions, key) then
                data.raw.recipe[key] = nil
            end
        end
        for _, module in pairs(data.raw.module) do
            if (module.limitation) then
                for key, value in pairs(module.limitation) do
                    if string.find(value, pattern) ~= nil and not table.contains(exceptions, value) then
                        module.limitation[key] = nil
                    end
                end
            end
        end
        for _, technology in pairs(data.raw.technology) do
            if (technology.effects) then
                for i, value in pairs(technology.effects) do
                    if value.recipe and string.find(value.recipe, pattern) ~= nil and not table.contains(exceptions, value.recipe) then
                        technology.effects[i] = nil
                    end
                end
            end
        end
    end,

    -- Finds recipes by an item being used either as an ingredient or a result
    -- @param itemName string The name of the item
    -- @return table A list of recipe names
    findByItem = function(itemName)
        local function containsItem(table)
            for _, ingredient in pairs(table) do
                if ingredient.name == itemName or ingredient[1] == itemName then
                    return true
                end
            end
            return false
        end
        local result = {}
        for _, recipe in pairs(data.raw.recipe) do
            local match = false
            if recipe.result == itemName
                    or recipe.results and containsItem(recipe.results)
                    or recipe.ingredients and containsItem(recipe.ingredients)
                    or recipe.normal and recipe.normal.result == itemName
                    or recipe.normal and recipe.normal.results and containsItem(recipe.normal.results)
                    or recipe.normal and recipe.normal.ingredients and containsItem(recipe.normal.ingredients)
                    or recipe.expensive and recipe.expensive.result == itemName
                    or recipe.expensive and recipe.expensive.results and containsItem(recipe.expensive.results)
                    or recipe.expensive and recipe.expensive.ingredients and containsItem(recipe.expensive.ingredients)
            then
                table.insert(result, recipe.name)
                match = true
            end
        end
        return result
    end,

    -- Removes recipes by an item being used either as an ingredient or a result
    -- @param itemName string The name of the item
    removeByItem = function(itemName)
        atom.util.log.debug("Removing recipes using item " .. itemName)
        local recipes = atom.util.recipe.findByItem(itemName)
        for _, recipe in pairs(recipes) do
            atom.util.log.debug("  " .. recipe)
            atom.util.recipe.removeByName(recipe)
        end
    end
}

-- Utility class for recipes
-- Pass a recipe name or a recipe table to get a Recipe object
-- @param value string|table The name of the recipe or the recipe table
function atom.util.Recipe(value)
    local recipeName
    local recipe

    if type(value) == "string" then
        recipeName = value
        recipe = data.raw.recipe[recipeName]
    elseif type(value) == "table" then
        recipeName = value.name
        recipe = value
    end

    if not recipe then
        atom.util.log.debug("Recipe not found: " .. recipeName)
        return nil
    end

    return {
        -- The recipe data
        prototype = recipe,

        -- Applies the recipe to the game
        apply = function()
            data:extend({ recipe })
        end,

        -- Replaces an existing result by name with a new result
        -- @param old string The name of the existing result
        -- @param new string The name of the new result
        -- @param amount number The amount of the new result
        -- @param expensiveAmount? number The amount of the new result for the expensive recipe
        replaceResult = function(old, new, amount, expensiveAmount)
            local function flat(table, amount)
                table.result = new
                table.result_count = amount
                if table.main_product == old then
                    table.main_product = new
                end
            end
            local function table(table, amount)
                for _, result in pairs(table.results) do
                    if result.name == old then
                        result.name = new
                        result.amount = amount
                    elseif result[1] == old then
                        result[1] = new
                        result[2] = amount
                    end
                end
                if table.main_product == old then
                    table.main_product = new
                end
            end
            if recipe.result then
                flat(recipe, amount)
            end
            if recipe.normal and recipe.normal.result then
                flat(recipe.normal, amount)
            end
            if recipe.expensive and recipe.expensive.result then
                flat(recipe.expensive, expensiveAmount or amount)
            end
            if recipe.results then
                table(recipe, amount)
            end
            if recipe.normal and recipe.normal.results then
                table(recipe.normal, amount)
            end
            if recipe.expensive and recipe.expensive.results then
                table(recipe.expensive, expensiveAmount or amount)
            end
        end,

        -- Allows productivity modules to be used for a recipe
        -- @param recipeName string The name of the recipe
        allowProductivity = function()
            for _, module in pairs(productivityModules) do
                if (module.limitation) then
                    table.insert(module.limitation, recipeName)
                end
            end
        end,

        -- Adds a recipe to a technology
        -- @param recipeName string The name of the recipe
        -- @param technology string The name of the technology
        unlockedByTechnology = function(technologyName)
            if not technologyName then
                return
            end
            for _, effect in pairs(data.raw.technology[technologyName].effects) do
                if effect.type == "unlock-recipe" and effect.recipe == recipeName then
                    return
                end
            end
            table.insert(data.raw.technology[technologyName].effects, { type = "unlock-recipe", recipe = recipeName })
        end,
    }
end