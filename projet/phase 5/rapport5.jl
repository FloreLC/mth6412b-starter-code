### A Pluto.jl notebook ###
# v0.19.12

using Markdown
using InteractiveUtils

# ╔═╡ a89f8fdc-6f65-11ed-1c24-9b5108ae25c6
begin
using PlutoUI

function display(filename)
  with_terminal() do
    open(filename, "r") do file
      for line in readlines(file)
        println(stdout, line)
      end
    end
  end
end

function display(filename, line1, line2)
  with_terminal() do
    open(filename, "r") do file
      lines = readlines(file)
      for i in line1:line2
        println(stdout, lines[i])
      end
    end
  end
end

struct Wow
filename
end

function Base.show(io::IO, ::MIME"image/png", w::Wow)
write(io, read(w.filename))
end
end

# ╔═╡ c28eaa50-b91c-4a29-8810-c559f756d19a
md"""
# Rapport 5
## Choisir les parametres
### Algorithmes

Comme le graphe representant les images ont un sommet relie a tous les autres sommets par une arete de poids 0, alors tout arbre couvrant de poids minimal est compose uniquement de ce sommet initial et de toutes les aretes nulles. L'algorithme RSL se base sur un MST pour fournir une tournee. Ainsi RSL n'est pas pertinent pour la resolution de nos problemes. \\
Nous allons donc nous concentrer sur les valeurs des parametres de notre implementation de l'algorithme HK.
### HK: Construire une tournee a partir d'un 1-arbre

Dans la plupart des cas, en tout cas avec nos machines, nous n'obtenons part l'algorithme HK non pas une tournee mais un 1-arbre approchant cette tournee.

Notre strategie est donc la suivante:
- Lancer l'algorithme HK
- Atteindre un de nos critere d'arret (a savoir: limite d'iteration, limite de temps, obtention d'une tournee)
- Si on obtient une tournee: la convertire en image reconstruite
- Sinon: (en s'inspirant de RSL)
    - Transformer le 1-arbre en arbre en enlevant le sommet initial
    - Lire cet arbre en post-ordre
    - Convertir la tournee ainsi obtenue en image
### HK: Adapter nos parametres
Les parametres sur lesquels nous intervenons sont les suivant:
- Algorithme pour produire un MST (Prim ou Kruskal)
- Pas adaptatif ou non (True ou False)
- Time limit (par defaut 2 minutes)
- iteration limit (par defaut 10 000)
- Valeur de pas (un interval de valeurs)

De nos experiences lors des precedentes phases du projet, nous avons retenu que Kruskal etait systematiquement plus rapide que Prim. Nous nous contentons donc de cet algorithme. Pour les memes raisons, nous ne considerons que des situation ou le pas est adaptatif. 
#### Impact du pas
Tout d'abord, considerons pour une meme image, avec une limite de temps de 2 minutes, differentes valeur de pas:
1. [0.5, 1.0], lenght = 125534.58
"""

# ╔═╡ 0d617a15-cab5-4222-a4f2-941e992e0eda
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/blue-hour-paris_lk_[0.5, 1.0]_true_kruskal_pre.png")

# ╔═╡ d8de9d7e-ef39-4a8a-a3f7-08f1474142bb
md"""
2. [0.5, 50.0], lenght =  125534.58
"""

# ╔═╡ 9bf33fae-e451-4669-9a49-6d76d236eb06
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/blue-hour-paris_lk_[0.5, 50.0]_true_kruskal_pre.png")

# ╔═╡ 7b8fc419-7a0f-485d-a6bb-a95b74f7a2d8
md"""
3. [0.5, 100.0], lenght = 125534.58
"""


# ╔═╡ b66df03a-9b7d-4f5a-92b4-4f21c4ddbb21
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/blue-hour-paris_lk_[0.5, 100.0]_true_kruskal_pre.png")

# ╔═╡ 6cd11def-aa96-4e36-8a24-6269402b2f20
md"""
4. [1.0, 10.0], lenght = 125534.58
"""

# ╔═╡ a021d457-40f9-4194-a95c-24f396f6b51c
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/blue-hour-paris_lk_[1.0, 10.0]_true_kruskal_pre.png")

# ╔═╡ afefed9c-b03e-4ff7-b1d1-36e330df5131
md"""
5. [20.0, 30.0], lenght = 125534.58
"""

# ╔═╡ cd0c751a-4387-4aed-9092-50fa2af0b1ff
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/blue-hour-paris_lk_[20.0, 30.0]_true_kruskal_pre.png")

# ╔═╡ 56ff91e1-6068-4c78-9849-0e633e6f38c8
md"""
6. [20.0, 30.0], lenght = 125534.58, sans pas adaptatif
"""

# ╔═╡ eeb84de7-3c60-4091-bc3d-384d3826f0fe
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/blue-hour-paris_lk_[20.0, 30.0]_false_kruskal_pre_120.png")

# ╔═╡ cabf0d44-d6fd-4664-b448-5d8d6349de48
md"""
7. [30.0, 50.0], lenght = 125534.58
"""

# ╔═╡ ccc73325-3a0a-4ca1-9515-ef6ce3d0d62f
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/blue-hour-paris_lk_[30.0, 50.0]_true_kruskal_pre.png")

# ╔═╡ c268d287-97af-4190-930d-66c7295863e7
md"""
Si la longueur des tournees obtenues est toujours la meme, on peut tout de meme remarquer que les images 5,6 et 7 se rapprochent plus de l'image originale que les 4 premieres.
En particulier il semble que le pas adaptatif, s'il permet d'avoir une meilleure idee de la structure de l'image, n'aggrege pas beaucoup de colonnes voisines.
"""

# ╔═╡ abe66ed7-b3b4-4abf-ad9e-425ace8d46fb
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/original/blue-hour-paris.png")

# ╔═╡ 8fa5ffb2-6552-4571-aece-4c46820a43cd
md"""
#### Impact du temps
Tout parametre egal par ailleurs, nous avons voulu etablir si la duree d'execution permettait de produire des solutions plus satisfaisantes. Il nous semble (et nous arrivons a la meme conclusions sur plusieurs instances) que la solution trouvee en 2 minutes n'est pas si differente de celles trouvees en 5, 10 ou 15 min.
1. 2min, lenght = 118111.05
"""

# ╔═╡ 3dc5ed22-6172-4d6e-98ad-4dd0f390c4f0
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/lower-kananaskis-lake_lk_[20.0, 30.0]_true_kruskal_pre.png")

# ╔═╡ e98f04c2-9a89-482c-b9fd-9b3a948b5b3c
md"""
2. 10 min, lenght = 118111.05
"""

# ╔═╡ 6e80add1-6eb6-4586-a80f-c1d1d06153e3
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/lower-kananaskis-lake_lk_[20.0, 30.0]_true_kruskal_pre_600.png")

# ╔═╡ f01b3cb5-c846-473a-988f-c287291715cb
md"""
3. 20 min, lenght = 118111.05
"""

# ╔═╡ fca334e1-06f9-41ee-bc21-41a2ee848d9b
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/lower-kananaskis-lake_lk_[20.0, 30.0]_true_kruskal_pre_1200.png")

# ╔═╡ b2d7c3e0-8b56-4637-9ea5-a6751b973fbf
md"""
Originale:
"""

# ╔═╡ e953b5cd-b313-4c29-b908-bcb646e81b9f
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/original/lower-kananaskis-lake.png")

# ╔═╡ 8c793f92-e4ef-46e6-abc9-788a8f88c619
md"""
L'amelioration ne nous semble pas valoir l'invesitssement en ressource.
## Pas adaptable
Enfin, nous comparons nos resultats avec et sans le pas adaptable sur quelques instances avec une limite de temps de 2min, un pas de [1.0, 2.0] et l'algorithme de Kruskal pour les MST:
- Sans le pas adaptable
"""

# ╔═╡ 41691877-4cb2-47ba-8787-47dd675d5d39
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/marlet2-radio-board_lk_[1.0, 2.0]_false_kruskal_pre_120.png")

# ╔═╡ a63c2255-3466-421b-9783-040fa0be2bac
md"""
- Avec le pas adaptable
"""

# ╔═╡ 3464e994-1557-4280-979a-2da40ac2ac14
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/reconstructed/marlet2-radio-board_lk_[1.0, 2.0]_true_kruskal_pre_120.png")

# ╔═╡ 7ad9cc87-a71a-4dd1-bce0-de45320de000
md"""
- Image originale:
"""

# ╔═╡ 44ff3522-ac51-4605-a0a2-7d79874e9516
Wow("/Users/flore/Desktop/Cours/MTH6412B/Projet/mth6412b-starter-code/projet/phase 5/shredder-julia/images/original/marlet2-radio-board.png")

# ╔═╡ 806e7f6f-a9b8-466c-9ead-13090682369f
md"""
On observe que bine que le pas adaptable donne des "clusters" de colonnes plus larges, les coutours des elements principaux restent bien visible avec ou sans le pas adaptable.
"""

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
PlutoUI = "~0.7.48"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.7.3"
manifest_format = "2.0"

[[deps.AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "8eaf9f1b4921132a4cff3f36a1d9ba923b14a481"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.4"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "eb7f0f8307f71fac7c606984ea5fb2817275d6e4"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.4"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"

[[deps.FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "c47c5fa4c5308f27ccaac35504858d8914e102f9"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.4"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[deps.JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "3c837543ddb02250ef42f4738347454f95079d4e"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.3"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[deps.LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[deps.LinearAlgebra]]
deps = ["Libdl", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[deps.MIMEs]]
git-tree-sha1 = "65f28ad4b594aebe22157d6fac869786a255b7eb"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "0.1.4"

[[deps.Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[deps.MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[deps.Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"

[[deps.Parsers]]
deps = ["Dates", "SnoopPrecompile"]
git-tree-sha1 = "b64719e8b4504983c7fca6cc9db3ebc8acc2a4d6"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.5.1"

[[deps.Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "efc140104e6d0ae3e7e30d56c98c4a927154d684"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.48"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[deps.REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[deps.Random]]
deps = ["SHA", "Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[deps.SnoopPrecompile]]
git-tree-sha1 = "f604441450a3c0569830946e5b33b78c928e1a85"
uuid = "66db9d55-30c0-4569-8b51-7e840670fc0c"
version = "1.0.1"

[[deps.Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[deps.SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[deps.TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[deps.Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[deps.Tricks]]
git-tree-sha1 = "6bac775f2d42a611cdfcd1fb217ee719630c4175"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.6"

[[deps.URIs]]
git-tree-sha1 = "ac00576f90d8a259f2c9d823e91d1de3fd44d348"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.4.1"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl", "OpenBLAS_jll"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[deps.p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"
"""

# ╔═╡ Cell order:
# ╟─a89f8fdc-6f65-11ed-1c24-9b5108ae25c6
# ╟─c28eaa50-b91c-4a29-8810-c559f756d19a
# ╟─0d617a15-cab5-4222-a4f2-941e992e0eda
# ╟─d8de9d7e-ef39-4a8a-a3f7-08f1474142bb
# ╟─9bf33fae-e451-4669-9a49-6d76d236eb06
# ╟─7b8fc419-7a0f-485d-a6bb-a95b74f7a2d8
# ╟─b66df03a-9b7d-4f5a-92b4-4f21c4ddbb21
# ╟─6cd11def-aa96-4e36-8a24-6269402b2f20
# ╟─a021d457-40f9-4194-a95c-24f396f6b51c
# ╟─afefed9c-b03e-4ff7-b1d1-36e330df5131
# ╟─cd0c751a-4387-4aed-9092-50fa2af0b1ff
# ╟─56ff91e1-6068-4c78-9849-0e633e6f38c8
# ╟─eeb84de7-3c60-4091-bc3d-384d3826f0fe
# ╟─cabf0d44-d6fd-4664-b448-5d8d6349de48
# ╟─ccc73325-3a0a-4ca1-9515-ef6ce3d0d62f
# ╟─c268d287-97af-4190-930d-66c7295863e7
# ╟─abe66ed7-b3b4-4abf-ad9e-425ace8d46fb
# ╟─8fa5ffb2-6552-4571-aece-4c46820a43cd
# ╟─3dc5ed22-6172-4d6e-98ad-4dd0f390c4f0
# ╟─e98f04c2-9a89-482c-b9fd-9b3a948b5b3c
# ╟─6e80add1-6eb6-4586-a80f-c1d1d06153e3
# ╟─f01b3cb5-c846-473a-988f-c287291715cb
# ╟─fca334e1-06f9-41ee-bc21-41a2ee848d9b
# ╟─b2d7c3e0-8b56-4637-9ea5-a6751b973fbf
# ╟─e953b5cd-b313-4c29-b908-bcb646e81b9f
# ╟─8c793f92-e4ef-46e6-abc9-788a8f88c619
# ╟─41691877-4cb2-47ba-8787-47dd675d5d39
# ╟─a63c2255-3466-421b-9783-040fa0be2bac
# ╟─3464e994-1557-4280-979a-2da40ac2ac14
# ╟─7ad9cc87-a71a-4dd1-bce0-de45320de000
# ╟─44ff3522-ac51-4605-a0a2-7d79874e9516
# ╟─806e7f6f-a9b8-466c-9ead-13090682369f
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
