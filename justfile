default:
  @just --choose

[private]
boards:
  for bm in $(yq eval -o=j build.yaml | jq -cr '.include[]'); do \
    board=$(echo $bm | jq -r '.board' -); \
    shield=$(echo $bm | jq -r '.shield' -); \
    out=$board; \
    [[ ! -z shield ]] && out=$out-$shield; \
    echo $out; \
  done

build board shield='':
  out={{board}} && \
  [[ ! -z "{{shield}}" ]] && out=$out-{{shield}} || echo "no shield provided" && \
  if [[ -f target/$out.uf2 ]]; then \
    mv target/$out.uf2 target/$out.uf2.bak; \
  elif [[ -f target/$out.bin ]]; then \
    mv target/$out.bin target/$out.bin.bak; \
  fi && \
  cd zmk/app && \
  west build -d build/$out -b {{board}} -- $([[ ! -z "{{shield}}" ]] && echo "-DSHIELD={{shield}}") -DZMK_CONFIG=$HOME/git/dan/zmk-config/config && \
  if [[ -f build/$out/zephyr/zmk.uf2 ]]; then \
    cp build/$out/zephyr/zmk.uf2 ../../target/$out.uf2; \
  else \
    cp build/$out/zephyr/zmk.bin ../../target/$out.bin; \
  fi

build-all: build-ferris build-osprette build-corneish-zen
build-ferris: (build 'ferris_rev02')
build-osprette: (build 'nice_nano_v2' 'osprette')
build-corneish-zen-left: (build 'corneish_zen_v1_left')
build-corneish-zen-right: (build 'corneish_zen_v1_right')
build-corneish-zen: build-corneish-zen-left build-corneish-zen-right
build-zaphod: (build 'zaphod')
