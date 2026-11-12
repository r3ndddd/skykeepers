import sys,json,argparse
from pathlib import Path
sys.path.insert(0,str(Path(__file__).resolve().parent))
from pipeline import *

def tree():
    bark=material('Cloudwood_Bark',(.18,.085,.035)); leaf=material('Cloudwood_Foliage',(.08,.32,.23))
    stem('Trunk',bark,(0,0,2),.45,4)
    ico('Canopy_Main',leaf,(0,0,5.7),(2.2,2.2,2.4))
    ico('Canopy_East',leaf,(1.35,0,4.7),(1.5,1.5,1.65))
    ico('Canopy_Northwest',leaf,(-1.15,1,4.8),(1.4,1.5,1.6))

def crystal():
    cyan=material('Skyglass_Cyan',(.025,.48,.85)); dark=material('Skyglass_Stone',(.11,.17,.24))
    stem('Stone_Base',dark,(0,0,.2),1,.4)
    gem('Crystal_Main',cyan,(0,0,.35),.7,2.65)
    gem('Crystal_East',cyan,(.72,0,.3),.24,.9,5)

def plant():
    green=material('Starbloom_Leaves',(.04,.25,.13)); violet=material('Starbloom_Petals',(.42,.12,.62)); gold=material('Starbloom_Core',(.9,.55,.07))
    stem('Stem',green,(0,0,.7),.09,1.4)
    ico('Leaf_East',green,(.38,0,.55),(.55,.18,.16))
    ico('Leaf_Northwest',green,(-.3,.24,.8),(.48,.2,.16))
    for i in range(5):
        a=i*math.tau/5
        obj=ico('Petal_'+str(i),violet,(.48*math.cos(a),.48*math.sin(a),1.55),(.5,.3,.2))
    ico('Flower_Core',gold,(0,0,1.7),(.32,.32,.3))

p=argparse.ArgumentParser();p.add_argument('--out',required=True)
args=p.parse_args(sys.argv[sys.argv.index('--')+1:])
root=Path(args.out);root.mkdir(parents=True,exist_ok=False)
results=[]
for key,title,size,budget,fn in [('cloudwood_tree_v001','CLOUDWOOD TREE',[5,8,5],1500,tree),('skyglass_crystal_v001','SKYGLASS CRYSTAL',[2,3,2],500,crystal),('starbloom_plant_v001','STARBLOOM PLANT',[2,2,2],500,plant)]:
    results.append(build_asset(root,key,title,size,budget,fn))
(root/'catalog.json').write_text(json.dumps(results,indent=2),encoding='utf-8')
print('ALL_ASSETS_VALIDATED',[(r['asset_key'],r['triangles']) for r in results])
