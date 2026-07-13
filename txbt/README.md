# Tchux Build Tools

<p align=center>
	<a href="">
		<img alt="TxBT 0.0.0 Release" src="https://badgen.net/static/Version/1.0.0/blue" width="100px">
	</a>
</p>

## About

TxBT is the set of tools needed to compile Tchux smoothly and without errors on any operating system.

## Dependencies:

You need to have Texinfo installed to build Binutils. You need to have GMP, MPC, and MPFR installed to build GCC

[More details](https://wiki.osdev.org/GCC_Cross-Compiler#Installing_Dependencies)

Others:
- xz
- bzip2

## Use

```bash
./txbt/build.sh arch-elf /home/your_user/Tchux/txbt/cross-compiler
```

## License

TxBT is licensed under a [GNU GPL 3.0](https://github.com/francisc0arauj0/Tchux/blob/main/LICENSE) license.