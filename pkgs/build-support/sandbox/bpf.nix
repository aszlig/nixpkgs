with import ../../lib;

rec {
  # BPF one arg statement
  bpf_stmt = code: k: {
    toString = "BPF_STMT(${concatStringsSep "+" code}, ${k})";
  };

  # BPF jump (jump if true/jump if false)
  bpf_jump = code: k: jt: jf: {
    toString = "BPF_STMT(${concatStringsSep "+" code}, ${k},"
             + " ${toString jt}, ${toString jf})";
  };

  # copy to accumulator
  ldwa   = bpf_stmt [ "BPF_LD"   "BPF_W"    "BPF_ABS" ]; # A <- P[k:4]
  ldha   = bpf_stmt [ "BPF_LD"   "BPF_H"    "BPF_ABS" ]; # A <- P[k:2]
  ldba   = bpf_stmt [ "BPF_LD"   "BPF_B"    "BPF_ABS" ]; # A <- P[k:1]
  ldwi   = bpf_stmt [ "BPF_LD"   "BPF_W"    "BPF_IND" ]; # A <- P[X+k:4]
  ldhi   = bpf_stmt [ "BPF_LD"   "BPF_H"    "BPF_IND" ]; # A <- P[X+k:2]
  ldbi   = bpf_stmt [ "BPF_LD"   "BPF_B"    "BPF_IND" ]; # A <- P[X+k:1]
  ldlen  = bpf_stmt [ "BPF_LD"   "BPF_W"    "BPF_LEN" ]; # A <- len
  ldimm  = bpf_stmt [ "BPF_LD"   "BPF_IMM"            ]; # A <- k
  ldmem  = bpf_stmt [ "BPF_LD"   "BPF_MEM"            ]; # A <- M[k]

  # copy to index
  ldximm = bpf_stmt [ "BPF_LDX"  "BPF_W"    "BPF_IMM" ]; # X <- k
  ldxmem = bpf_stmt [ "BPF_LDX"  "BPF_W"    "BPF_MEM" ]; # X <- M[k]
  ldxlen = bpf_stmt [ "BPF_LDX"  "BPF_W"    "BPF_LEN" ]; # X <- len

  # copy accumulator to memory
  st     = bpf_stmt [ "BPF_ST"                        ]; # M[k] <- A

  # copy index to memory
  stx    = bpf_stmt [ "BPF_STX"                       ]; # M[k] <- X

  # arithmetics
  add    = bpf_stmt [ "BPF_ALU"  "BPF_ADD"  "BPF_K"   ]; # A <- A + k
  sub    = bpf_stmt [ "BPF_ALU"  "BPF_SUB"  "BPF_K"   ]; # A <- A - k
  mul    = bpf_stmt [ "BPF_ALU"  "BPF_MUL"  "BPF_K"   ]; # A <- A * k
  div    = bpf_stmt [ "BPF_ALU"  "BPF_DIV"  "BPF_K"   ]; # A <- A / k
  and    = bpf_stmt [ "BPF_ALU"  "BPF_AND"  "BPF_K"   ]; # A <- A & k
  or     = bpf_stmt [ "BPF_ALU"  "BPF_OR"   "BPF_K"   ]; # A <- A | k
  lsh    = bpf_stmt [ "BPF_ALU"  "BPF_LSH"  "BPF_K"   ]; # A <- A << k
  rsh    = bpf_stmt [ "BPF_ALU"  "BPF_RSH"  "BPF_K"   ]; # A <- A >> k
  addx   = bpf_stmt [ "BPF_ALU"  "BPF_ADD"  "BPF_X"   ]; # A <- A + X
  subx   = bpf_stmt [ "BPF_ALU"  "BPF_SUB"  "BPF_X"   ]; # A <- A - X
  mulx   = bpf_stmt [ "BPF_ALU"  "BPF_MUL"  "BPF_X"   ]; # A <- A * X
  divx   = bpf_stmt [ "BPF_ALU"  "BPF_DIV"  "BPF_X"   ]; # A <- A / X
  andx   = bpf_stmt [ "BPF_ALU"  "BPF_AND"  "BPF_X"   ]; # A <- A & X
  orx    = bpf_stmt [ "BPF_ALU"  "BPF_OR"   "BPF_X"   ]; # A <- A | X
  lshx   = bpf_stmt [ "BPF_ALU"  "BPF_LSH"  "BPF_X"   ]; # A <- A << X
  rshx   = bpf_stmt [ "BPF_ALU"  "BPF_RSH"  "BPF_X"   ]; # A <- A >> X
  neg    = bpf_stmt [ "BPF_ALU"  "BPF_NEG"            ]; # A <- -A

  # flow control
  jmp    = bpf_jump [ "BPF_JMP"  "BPF_JA"             ]; # += k
  jg     = bpf_jump [ "BPF_JMP"  "BPF_JGT"  "BPF_K"   ]; # += (A > k)  ? jt : jf
  jge    = bpf_jump [ "BPF_JMP"  "BPF_JGE"  "BPF_K"   ]; # += (A >= k) ? jt : jf
  je     = bpf_jump [ "BPF_JMP"  "BPF_JEQ"  "BPF_K"   ]; # += (A == k) ? jt : jf
  jset   = bpf_jump [ "BPF_JMP"  "BPF_JSET" "BPF_K"   ]; # += (A & k)  ? jt : jf
  jgx    = bpf_jump [ "BPF_JMP"  "BPF_JGT"  "BPF_X"   ]; # += (A > X)  ? jt : jf
  jgex   = bpf_jump [ "BPF_JMP"  "BPF_JGE"  "BPF_X"   ]; # += (A >= X) ? jt : jf
  jex    = bpf_jump [ "BPF_JMP"  "BPF_JEQ"  "BPF_X"   ]; # += (A == X) ? jt : jf
  jsetx  = bpf_jump [ "BPF_JMP"  "BPF_JSET" "BPF_X"   ]; # += (A & X)  ? jt : jf

  # termination
  ret    = bpf_stmt [ "BPF_RET"  "BPF_K"              ]; # return A
  reta   = bpf_stmt [ "BPF_RET"  "BPF_A"              ]; # return k

  # miscellaneous
  tax    = bpf_stmt [ "BPF_MISC" "BPF_TAX"            ]; # A -> X
  txa    = bpf_stmt [ "BPF_MISC" "BPF_TXA"            ]; # X -> A
}
