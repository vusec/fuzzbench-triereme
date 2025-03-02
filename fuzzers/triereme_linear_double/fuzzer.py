# Copyright 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
''' Uses the SymCC-AFL hybrid from SymCC. '''

from fuzzers.symcc_libafl_double import fuzzer as symcc_fuzzer
from fuzzers.triereme_trie_double import fuzzer as trie_fuzzer


def build():
    """Build an AFL version and SymCC version of the benchmark"""
    symcc_fuzzer.build()


def fuzz(input_corpus, output_corpus, target_binary):
    """
    Launches an instance of AFL++, as well as the Triereme helper.
    """
    trie_fuzzer.fuzz(input_corpus, output_corpus, target_binary, use_trie=False)
