local artilleryWormTurret = util.table.deepcopy(data.raw.turret["behemoth-worm-turret"])
artilleryWormTurret.name = "artillery-worm-turret"
artilleryWormTurret.attack_parameters.cooldown = 500 --behemoth-worm-turret 4
artilleryWormTurret.attack_parameters.range = 128 --behemoth-worm-turret 48 
artilleryWormTurret.prepare_range = 135 --behemoth-worm-turret 84 
artilleryWormTurret.max_health = 150 --behemoth-worm-turret 750
artilleryWormTurret.resistances = {}

data:extend({
    artilleryWormTurret
    })