# Tchux

<p align=center>
	<a href="">
		<img alt="Tchux 0.0.0 Release" src="https://badgen.net/static/Release/0.0.0/blue" width="100px">
	</a>
</p>

## About

Tchux is an operating system that I created as a hands-on learning project. Its main goal is to explore how modern operating systems work by building one from scratch.

## Building

To build Tchux it is strongly advised use [Tchux Cross-Compiler](#cross-compiler) and [Visual Studio Code](https://code.visualstudio.com/)

## TxCC

You need to have Texinfo installed to build Binutils. You need to have GMP, MPC, and MPFR installed to build GCC

[More details](https://wiki.osdev.org/GCC_Cross-Compiler#Installing_Dependencies)

Others:
- xz
- bzip2

Install

```bash
./scripts/cc.sh arch-elf /home/your_user/Tchux/txcc
```

## License

Tchux is licensed under a [GNU GPL 3.0](https://github.com/francisc0arauj0/Tchux/blob/main/LICENSE) license.