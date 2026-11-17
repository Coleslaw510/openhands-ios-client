from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse, HTMLResponse
import time
import os
import json
import random

app = FastAPI(title="Custom Dragon City - Production Edition")

SAVE_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "save.json")

BASE_DRAGONS = [
    {"id": 1, "name": "Blaze", "element": "Fire", "rarity": "Common", "gold_per_min": 15, "icon": "🔥"},
    {"id": 2, "name": "Tide", "element": "Water", "rarity": "Common", "gold_per_min": 15, "icon": "💧"},
    {"id": 3, "name": "Pebble", "element": "Earth", "rarity": "Common", "gold_per_min": 15, "icon": "🌍"},
    {"id": 4, "name": "Breeze", "element": "Air", "rarity": "Common", "gold_per_min": 15, "icon": "💨"},
    {"id": 5, "name": "Spark", "element": "Lightning", "rarity": "Common", "gold_per_min": 20, "icon": "⚡"},
    {"id": 6, "name": "Fern", "element": "Plant", "rarity": "Common", "gold_per_min": 15, "icon": "🌿"},
    {"id": 7, "name": "Frost", "element": "Ice", "rarity": "Common", "gold_per_min": 18, "icon": "❄️"},
    {"id": 8, "name": "Gleam", "element": "Light", "rarity": "Common", "gold_per_min": 25, "icon": "✨"},
    {"id": 9, "name": "Rivet", "element": "Metal", "rarity": "Common", "gold_per_min": 22, "icon": "⚙️"},
    {"id": 10, "name": "Twinkle", "element": "Star", "rarity": "Common", "gold_per_min": 30, "icon": "🌟"}
]

HYBRID_COMBOS = {
    ("Fire", "Water"): {"name": "Steam", "rarity": "Rare", "icon": "♨️"},
    ("Fire", "Earth"): {"name": "Clay", "rarity": "Rare", "icon": "🧱"},
    ("Fire", "Air"): {"name": "Smoke", "rarity": "Rare", "icon": "💨"},
    ("Fire", "Lightning"): {"name": "Crackle", "rarity": "Rare", "icon": "⚡"},
    ("Fire", "Plant"): {"name": "Ember", "rarity": "Rare", "icon": "🔥"},
    ("Water", "Earth"): {"name": "Mud", "rarity": "Rare", "icon": "🌊"},
    ("Water", "Air"): {"name": "Mist", "rarity": "Rare", "icon": "💧"},
    ("Earth", "Air"): {"name": "Sand", "rarity": "Rare", "icon": "🏜️"}
}

def load_save():
    if os.path.exists(SAVE_FILE):
        try:
            with open(SAVE_FILE, "r") as f:
                return json.load(f)
        except:
            pass
    
    default_state = {
        "user": {
            "id": "user_pro_1",
            "name": "DragonMaster Pro",
            "level": 5,
            "xp": 1200,
            "next_level_xp": 2500,
            "gold": 12500,
            "food": 5400,
            "gems": 150
        },
        "islands": [
            {
                "id": 1,
                "name": "Primary Sanctuary Island",
                "unlocked": True,
                "habitats": [
                    {
                        "id": 101,
                        "name": "Fire Sanctuary",
                        "type": "Fire",
                        "level": 2,
                        "capacity": 4,
                        "gold_stored": 450,
                        "max_gold": 2000,
                        "dragons": [1]
                    },
                    {
                        "id": 102,
                        "name": "Water Pool",
                        "type": "Water",
                        "level": 1,
                        "capacity": 3,
                        "gold_stored": 200,
                        "max_gold": 1000,
                        "dragons": [2]
                    }
                ]
            }
        ],
        "dragons": [
            {
                "id": 1,
                "name": "Blaze",
                "element": "Fire",
                "level": 4,
                "rarity": "Common",
                "gold_per_min": 25,
                "icon": "🔥"
            },
            {
                "id": 2,
                "name": "Tide",
                "element": "Water",
                "level": 3,
                "rarity": "Common",
                "gold_per_min": 20,
                "icon": "💧"
            }
        ],
        "hatchery": [
            {"id": 1, "egg_name": "Pebble Egg", "element": "Earth", "icon": "🌍"}
        ],
        "farms": [
            {"id": 1, "level": 2, "status": "ready", "crop": "Mega Munchies", "yield": 1200},
            {"id": 2, "level": 1, "status": "idle", "crop": None, "yield": 600}
        ]
    }
    save_state(default_state)
    return default_state

def save_state(state):
    with open(SAVE_FILE, "w") as f:
        json.dump(state, f, indent=2)

@app.get("/", response_class=HTMLResponse)
def read_root():
    html_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "index.html")
    if os.path.exists(html_path):
        with open(html_path, "r") as f:
            return f.read()
    return "<h1>Custom Dragon City Server Running</h1>"

@app.get("/api/state")
def get_state():
    return JSONResponse(content=load_save())

@app.post("/api/action/collect_gold")
async def collect_gold(request: Request):
    data = await request.json()
    habitat_id = data.get("habitat_id")
    state = load_save()
    collected = 0
    for island in state["islands"]:
        for hab in island["habitats"]:
            if hab["id"] == habitat_id:
                collected = hab["gold_stored"]
                hab["gold_stored"] = 0
                state["user"]["gold"] += collected
                state["user"]["xp"] += int(collected / 5)
                break
    save_state(state)
    return JSONResponse(content={"success": True, "collected": collected, **state})

@app.post("/api/action/feed_dragon")
async def feed_dragon(request: Request):
    data = await request.json()
    dragon_id = data.get("dragon_id")
    state = load_save()
    cost = 150
    if state["user"]["food"] < cost:
        return JSONResponse(content={"success": False, "error": "Not enough food!"}, status_code=400)
    
    state["user"]["food"] -= cost
    for d in state["dragons"]:
        if d["id"] == dragon_id:
            d["level"] += 1
            d["gold_per_min"] += 10
            break
    save_state(state)
    return JSONResponse(content={"success": True, **state})

@app.post("/api/action/harvest_farm")
async def harvest_farm(request: Request):
    data = await request.json()
    farm_id = data.get("farm_id")
    state = load_save()
    harvested = 0
    for farm in state["farms"]:
        if farm["id"] == farm_id and farm["status"] == "ready":
            harvested = farm["yield"]
            state["user"]["food"] += harvested
            farm["status"] = "idle"
            farm["crop"] = None
            break
    save_state(state)
    return JSONResponse(content={"success": True, "harvested": harvested, **state})

@app.post("/api/action/plant_farm")
async def plant_farm(request: Request):
    data = await request.json()
    farm_id = data.get("farm_id")
    cost = 300
    state = load_save()
    if state["user"]["gold"] < cost:
        return JSONResponse(content={"success": False, "error": "Not enough gold!"}, status_code=400)
    
    state["user"]["gold"] -= cost
    for farm in state["farms"]:
        if farm["id"] == farm_id:
            farm["status"] = "ready"
            farm["crop"] = "Dragon Root"
            farm["yield"] = 1000
            break
    save_state(state)
    return JSONResponse(content={"success": True, **state})

@app.post("/api/action/hatch_egg")
async def hatch_egg(request: Request):
    data = await request.json()
    egg_id = data.get("egg_id")
    state = load_save()
    target_egg = None
    new_hatchery = []
    for egg in state["hatchery"]:
        if egg["id"] == egg_id:
            target_egg = egg
        else:
            new_hatchery.append(egg)
    
    if not target_egg:
        return JSONResponse(content={"success": False, "error": "Egg not found"}, status_code=400)
    
    state["hatchery"] = new_hatchery
    new_id = max([d["id"] for d in state["dragons"]], default=0) + 1
    new_dragon = {
        "id": new_id,
        "name": target_egg["egg_name"].replace(" Egg", ""),
        "element": target_egg["element"],
        "level": 1,
        "rarity": "Common",
        "gold_per_min": 15,
        "icon": target_egg["icon"]
    }
    state["dragons"].append(new_dragon)
    if state["islands"] and state["islands"][0]["habitats"]:
        state["islands"][0]["habitats"][0]["dragons"].append(new_id)
        
    save_state(state)
    return JSONResponse(content={"success": True, "new_dragon": new_dragon, **state})

@app.post("/api/action/breed")
async def breed_dragons(request: Request):
    state = load_save()
    cost = 30
    if state["user"]["gems"] < cost:
        return JSONResponse(content={"success": False, "error": "Not enough gems!"}, status_code=400)
    
    state["user"]["gems"] -= cost
    
    # Pick random hybrid
    combo_key = random.choice(list(HYBRID_COMBOS.keys()))
    hybrid = HYBRID_COMBOS[combo_key]
    
    new_egg_id = max([e["id"] for e in state["hatchery"]], default=0) + 1
    new_egg = {
        "id": new_egg_id,
        "egg_name": f"{hybrid['name']} Egg",
        "element": f"{combo_key[0]}/{combo_key[1]}",
        "icon": hybrid["icon"]
    }
    state["hatchery"].append(new_egg)
    save_state(state)
    return JSONResponse(content={"success": True, "new_egg": new_egg, **state})

@app.post("/api/action/buy_habitat")
async def buy_habitat(request: Request):
    state = load_save()
    cost = 2500
    if state["user"]["gold"] < cost:
        return JSONResponse(content={"success": False, "error": "Not enough gold!"}, status_code=400)
    
    state["user"]["gold"] -= cost
    elements = ["Fire", "Water", "Earth", "Air", "Lightning", "Plant", "Ice", "Light", "Metal", "Star"]
    elem = random.choice(elements)
    icons = {"Fire": "🔥", "Water": "💧", "Earth": "🌍", "Air": "💨", "Lightning": "⚡", "Plant": "🌿", "Frost": "❄️", "Light": "✨", "Metal": "⚙️", "Star": "🌟"}
    
    new_hab_id = max([h["id"] for island in state["islands"] for h in island["habitats"]], default=100) + 1
    new_hab = {
        "id": new_hab_id,
        "name": f"{elem} Sanctuary",
        "type": elem,
        "level": 1,
        "capacity": 4,
        "gold_stored": 0,
        "max_gold": 1500,
        "dragons": []
    }
    state["islands"][0]["habitats"].append(new_hab)
    save_state(state)
    return JSONResponse(content={"success": True, **state})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8011)
