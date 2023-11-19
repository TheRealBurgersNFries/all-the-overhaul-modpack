--need to sort some more stuff, currently working.

-- import groups
require("groups/fluid")
require("groups/transport")
require("groups/terrain")
require("groups/production")
require("groups/module")
require("groups/logistics")
require("groups/resources")
require("groups/petrochemistry")
require("groups/intermediate-products")
require("groups/combat")

-- ordersgroup
require("groups/ordersgroup")

-- re-stack
require("re_stack")

-- final fixes prototypes
if mods["RampantArsenal"] then
    require("prototypes/rampant-arsenal-final")
end
require("prototypes/common-final")
require("prototypes/technology/technology")
require("prototypes/recipe/fix")
require("prototypes/item/fix")
require("prototypes/grid/adjust")
require("prototypes/entity/fu_magnet_entity")
require("prototypes/evolution/evolutiondata")
require("prototypes/sorting/sorter")
require("prototypes/entity/fix")