<div align="center" id="top"> 
  <img src="./.github/app.gif" alt="Spaceinvaders" />

  &#xa0;

  <!-- <a href="https://spaceinvaders.netlify.app">Demo</a> -->
</div>

<h1 align="center">FPGA Space Invaders</h1>

<p align="center">
  <img alt="Github top language" src="https://img.shields.io/github/languages/top/colbarron/spaceinvaders?color=56BEB8">

  <img alt="Github language count" src="https://img.shields.io/github/languages/count/colbarron/spaceinvaders?color=56BEB8">

  <img alt="Repository size" src="https://img.shields.io/github/repo-size/colbarron/spaceinvaders?color=56BEB8">

  <img alt="License" src="https://img.shields.io/github/license/colbarron/spaceinvaders?color=56BEB8">

  <!-- <img alt="Github issues" src="https://img.shields.io/github/issues/colbarron/spaceinvaders?color=56BEB8" /> -->

  <!-- <img alt="Github forks" src="https://img.shields.io/github/forks/colbarron/spaceinvaders?color=56BEB8" /> -->

  <!-- <img alt="Github stars" src="https://img.shields.io/github/stars/colbarron/spaceinvaders?color=56BEB8" /> -->
</p>

<!-- Status -->

<!-- <h4 align="center"> 
	🚧  Spaceinvaders 🚀 Under construction...  🚧
</h4> 

<hr> -->

<p align="center">
  <a href="#dart-about">About</a> &#xa0; | &#xa0;
  <a href="#rocket-technologies">Tools</a> &#xa0; | &#xa0;
  <a href="#white_check_mark-requirements">Requirements</a> &#xa0; | &#xa0;
  <a href="#checkered_flag-starting">Starting</a> &#xa0; | &#xa0;
  <a href="#memo-license">License</a> &#xa0; | &#xa0;
  <a href="https://github.com/colbarron" target="_blank">Author</a>
</p>

<br>

## About ##

In this project, we aim to make use of the iCEbreaker FPGA and open    \
source tools to implement the classic Space Invaders game.

## Tools ##

The following tools were used in this project:

- [Yosys Open SYnthesis Suite](https://yosyshq.net/yosys/)
- [icestorm-40](https://clifford.at/icestorm)
- [Verilator](https://www.veripool.org/verilator/)

## :white_check_mark: Requirements ##

Before starting :checkered_flag:, you need to have [iCEbreaker FPGA or Lattice-based FPGA](https://1bitsquared.com/products/icebreaker) and tools mentioned in the Tools section.

## :checkered_flag: Starting ##

```bash
# If said tools are installed then continue below:

# Clone this project
$ git clone https://github.com/colbarron/spaceinvaders

# Access
$ cd spaceinvaders/top_module

# Make the 
$ make prog

# Make sure the FPGA is connected and has the DVI Pmod attached.
# At this point the FPGA should be programmed and you can start playing the game.
```

## :memo: License ##

This project is under license from MIT. For more details, see the [LICENSE](LICENSE) file.


Made by <a href="https://github.com/colbarron" target="_blank">Gary Mejia</a>
and <a href="https://github.com/edro360" target="_blank">Edwin Rojas</a>

&#xa0;

<a href="#top">Back to top</a>
