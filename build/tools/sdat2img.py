#!/usr/bin/env python

from __future__ import print_function

import argparse
import os
import sys

try:
    import brotli
    BROTLI_AVAILABLE = True
except ImportError:
    BROTLI_AVAILABLE = False


class SourceFile(object):
    def __init__(self, file_path, use_brotli):
        self.src = open(file_path, 'rb')
        self.use_brotli = use_brotli
        if self.use_brotli:
            self.decompressed = ''
            self.decompressor = brotli.Decompressor()

    def _read_brotli(self, size):
        while len(self.decompressed) < size:
            compressed_data = self.src.read(size)
            self.decompressed += self.decompressor.decompress(compressed_data)
        to_return = self.decompressed[:size]
        self.decompressed = self.decompressed[size:]
        return to_return

    def read(self, size):
        if self.use_brotli:
            return self._read_brotli(size)
        else:
            return self.src.read(size)

    def close(self):
        self.src.close()

    def __enter__(self):
        return self

    def __exit__(self, *args):
        self.close()


def extract(transfer_list_path, source_path, use_brotli, output_path):
    block_size = 0x1000
    with open(transfer_list_path, 'r') as transfer_list, \
            SourceFile(source_path, use_brotli) as src, \
            open(output_path, 'wb') as dst:
        version = int(transfer_list.readline())
        total_blocks = int(transfer_list.readline())
        if version >= 2:
            # how many stash entries are needed simultaneously
            transfer_list.readline()
            # maximum number of blocks that will be stashed simultaneously
            transfer_list.readline()

        last_block = 0
        blocks_written = 0
        for line in transfer_list:
            line = line.strip()
            if not line:
                continue

            cmd, arg = line.split(' ', 1)
            if cmd == "new":
                ranges = [int(i) for i in arg.split(',')[1:]]
                for begin, end in zip(ranges[::2], ranges[1::2]):
                    blocks_count = end - begin
                    dst.seek(begin * block_size)
                    dst.write(src.read(blocks_count * block_size))
                    blocks_written += blocks_count
                    last_block = max(last_block, end)
            elif cmd == "zero":
                ranges = [int(i) for i in arg.split(',')[1:]]
                for begin, end in zip(ranges[::2], ranges[1::2]):
                    blocks_written += end - begin
                    last_block = max(last_block, end)
            elif cmd == "erase":
                # Nothing to do
                pass
            else:
                print("'{}' is not a supported command".format(cmd),
                      file=sys.stderr)

        dst.truncate(last_block * block_size)

    if total_blocks != blocks_written:
        print("Warning: {}/{} blocks written".format(
            blocks_written, total_blocks), file=sys.stderr)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("transfer_list",
                        help="Path to the transfer list file")
    parser.add_argument("source",
                        help="Path to the source data file")
    parser.add_argument("output", nargs="?", default="system.img",
                        help="Path to the output file")
    parser.add_argument("-f", "--force", action="store_true",
                        help="Overwrite output file")

    if BROTLI_AVAILABLE:
        parser.add_argument("-b", "--brotli", action="store_true",
                            help="The source file is brotli compressed")
    else:
        parser.epilog = "Install brotlipy to support brotli compressed files."

    args = parser.parse_args()

    if os.path.exists(args.output) and not args.force:
        print("Specify a different path or use --force", file=sys.stderr)
        exit(1)

    use_brotli = BROTLI_AVAILABLE and args.brotli
    extract(args.transfer_list, args.source, use_brotli, args.output)
