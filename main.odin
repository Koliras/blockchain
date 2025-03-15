package main

import "core:crypto/hash"
import "core:encoding/hex"
import "core:fmt"
import "core:time"

Block :: struct {
	index:        int,
	timestamp:    i64,
	// for now it will be just int
	transactions: int,
	hash:         string,
	prev_hash:    string,
}

Block_Creation_Error :: union {}

block_calculate_hash :: proc(block: ^Block) -> string {
	input := fmt.aprint(
		block.index,
		block.timestamp,
		block.transactions,
		block.prev_hash,
		sep = "",
	)

	ctx: hash.Context
	digest := make([]byte, hash.DIGEST_SIZES[hash.Algorithm.SHA256])
	defer delete(digest)

	hash.init(&ctx, hash.Algorithm.SHA256)
	hash.update(&ctx, transmute([]byte)input)
	hash.final(&ctx, digest)

	return string(hex.encode(digest))
}

block_create :: proc(prev_block: ^Block, txs: int) -> (Block, Block_Creation_Error) {
	block := Block {
		index        = prev_block.index + 1,
		timestamp    = time.time_to_unix(time.now()),
		transactions = txs,
		prev_hash    = prev_block.hash,
	}
	block.hash = block_calculate_hash(&block)

	return block, nil
}

block_is_valid :: proc(new_block, prev_block: ^Block) -> bool {
	return(
		new_block.index - 1 == prev_block.index &&
		new_block.prev_hash == prev_block.hash &&
		block_calculate_hash(new_block) == new_block.hash \
	)
}

main :: proc() {
	block := Block{1, 66666666, 2, "hash", "prevhash"}
	block.hash = block_calculate_hash(&block)
	fmt.println(block.hash)
}
