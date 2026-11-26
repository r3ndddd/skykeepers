-- All balance values are user-approved; rarity assignments await a GDD decision.
local Catalog = {}
Catalog.RarityLevels = table.freeze({"TIER_1", "TIER_2", "TIER_3", "TIER_4", "TIER_5"})
Catalog.Zones = {
 WhisperingMeadows = {name="Whispering Meadows", gathers=9, drops={
  {id="Cloudwood", name="Cloudwood", probability=0.70, value=5},
  {id="Skyglass", name="Skyglass", probability=0.25, value=12},
  {id="Starbloom", name="Starbloom", probability=0.05, value=30},
 }},
 CrystalRuins = {name="Crystal Ruins", gathers=7, drops={
  {id="Mistwood", name="Mistwood", probability=0.55, value=12},
  {id="Moonstone", name="Moonstone", probability=0.40, value=30},
  {id="AncientBark", name="Ancient Bark", probability=0.05, value=80},
 }},
 StormTemple = {name="Storm Temple", gathers=4, drops={
  {id="StormEssence", name="Storm Essence", probability=0.60, value=30},
  {id="CelestialOre", name="Celestial Ore", probability=0.38, value=80},
  {id="TempestCore", name="Tempest Core", probability=0.02, value=220},
 }},
}
Catalog.ById = {}
for zoneId, zone in pairs(Catalog.Zones) do
 for _, item in ipairs(zone.drops) do
  assert(Catalog.ById[item.id] == nil, "duplicate resource id")
  item.zone=zoneId
  item.rarityStatus="PENDING_APPROVAL"
  Catalog.ById[item.id]=item
  table.freeze(item)
 end
 table.freeze(zone.drops)
 table.freeze(zone)
end
table.freeze(Catalog.Zones)
table.freeze(Catalog.ById)
return table.freeze(Catalog)
