include("Reconstruct.jl")

const PROJECT_PATH = "/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet"
filename = "blue-hour-paris"
picture = load(PROJECT_PATH * "/phase 5/shredder-julia/images/shuffled/$(filename).png")

# algorithm parameterization
const TOUR_ALGO = "HK"
const READ = "pre"
const STEP = [1.0, 150.0]
const ADAPT = true
const RAND_ROOT = true
const TL = 300
const ALGO = kruskal

# perform the procedure
reconstruct(filename, TOUR_ALGO, READ, STEP, ADAPT, RAND_ROOT, TL, ALGO)