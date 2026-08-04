```
$ podman pull kali-rolling
$ podman run --tty --interactive kali-rolling

# apt update
# apt install -y bc binwalk bsdextrautils firmware-mod-kit python2 wget xxd zip
# ln -s /usr/bin/python2 /usr/bin/python

# git clone https://github.com/maurice-w/zyxel-pmg-3000-mod-kit
# cd zyxel-pmg-3000-mod-kit

# wget 'https://gist.github.com/maurice-w/faeb60bf8201ce70391873bcb9059bc2/raw/1c6e70a86c231cc7b951e84690de3c1e5c436623/Zyxel_PMG3000-D20B_V1.00(ABVJ.0)b3v_2021-05-08.zip'
# wget 'https://gist.github.com/maurice-w/faeb60bf8201ce70391873bcb9059bc2/raw/1c6e70a86c231cc7b951e84690de3c1e5c436623/Zyxel_PMG3000-D20B_V1.00(ABVJ.1)b1i_2026-02-06.zip'
# unzip 'Zyxel*'
# ./mod.sh V1.00\(ABVJ.1\)b1i_2026-02-06.upf V1.00\(ABVJ.0\)b3v_2021-05-08.upf
```
