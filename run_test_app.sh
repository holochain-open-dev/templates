#!/usr/bin/bash
# Run this inside `nix develop`
set -e

DIR=$(pwd)

nix shell .#hc-scaffold-app-template --command bash -c "

cd /tmp
rm -rf forum-lit-open-dev

hc-scaffold web-app forum-lit-open-dev --setup-nix true 
"

cd /tmp/forum-lit-open-dev

nix develop --override-input scaffolding "path:$DIR" --command bash -c "

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

hc-scaffold zome profiles --integrity dnas/forum/zomes/integrity/ --coordinator dnas/forum/zomes/coordinator/
rm -rf dnas/forum/zomes/coordinator/profiles
rm -rf dnas/forum/zomes/integrity/profiles
head -n -5 Cargo.toml > Cargo.tmp && mv Cargo.tmp Cargo.toml

pnpm i

pnpm -F ui format
pnpm -F ui lint
pnpm -F ui build

pnpm t
"
