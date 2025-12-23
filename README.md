本项目使用Icarus Verilog 进行仿真  
在sim文件夹的对应目录下有测试文件`tb.v`文件和波形文件`.vcd`  
(`.view`是插件波形渲染器生成的中间文件，可以忽略)    
波形文件可以使用gtkwave进行查看  
  
另外由于Icarus Verilog对Xilinx IP支持有问题，`Risc5CPU_tb.vcd`文件中无法看到MemDout_mem的数据。  