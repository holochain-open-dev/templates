#!/usr/bin/bash
set -e

DIR=$(pwd)

nix shell --accept-flake-config .#hc-scaffold-app-template --command bash -c "
cd /tmp
rm -rf forum-lit-open-dev

hc-scaffold web-app forum-lit-open-dev --setup-nix true -F --package-manager pnpm
"

cd /tmp/forum-lit-open-dev

nix develop --accept-flake-config --override-input scaffolding "path:$DIR" --command bash -c "

set -e
hc-scaffold dna forum 

hc-scaffold zome posts --integrity dnas/forum/zomes/integrity/ --coordinator dnas/forum/zomes/coordinator/
hc-scaffold entry-type post --reference-entry-hash false --crud crud --link-from-original-to-each-update true --fields title:String:TextField,needs:Vec\<String\>:TextField
hc-scaffold entry-type comment --reference-entry-hash false --crud crud --link-from-original-to-each-update false --fields post_hash:ActionHash::Post
hc-scaffold entry-type like --reference-entry-hash false --crud crd --fields like_hash:Option\<ActionHash\>::Like,image_hash:EntryHash:Image,agent:AgentPubKey:SearchAgent
hc-scaffold entry-type certificate --reference-entry-hash false --crud cr --fields post_hash:ActionHash::Post,agent:AgentPubKey::certified,certifications_hashes:Vec\<EntryHash\>::Certificate,certificate_type:Enum::CertificateType:TypeOne.TypeTwo,dna_hash:DnaHash

hc-scaffold collection global all_posts post 
hc-scaffold collection by-author posts_by_author post
hc-scaffold collection global all_posts_entry_hash post:EntryHash
hc-scaffold collection by-author posts_by_author_entry_hash post:EntryHash

hc-scaffold link-type post like --delete true --bidirectional false
hc-scaffold link-type comment like --delete true --bidirectional false
hc-scaffold link-type certificate like --delete false --bidirectional false
hc-scaffold link-type agent:creator post --delete false --bidirectional false

git add .

sed -i 's/TODO:REPLACE_ME_WITH_THE_DNA_WITH_THE_PROFILES_ZOME/forum/g' ui/src/holochain-app.ts  
nix run github:holochain-open-dev/profiles/nixify#scaffold --refresh -- --local-dna-to-add-the-zome-to forum --local-npm-package-to-add-the-ui-to ui

pnpm i

pnpm -F ui format
pnpm -F ui lint
pnpm -F ui build

pnpm t
"
