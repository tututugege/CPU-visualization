`timescale 1 ns / 1 ns

	module painterengine_gpu
		(
			/////////////////////////////////////////////////////////////
			//clock
			/////////////////////////////////////////////////////////////
			
			//input clk
			input wire          i_wire_clock,
			input wire          S_AXI_ACLK,
			//pixel clock

			/////////////////////////////////////////////////////////////
			//clock
			/////////////////////////////////////////////////////////////
			//enable
			input wire   		i_wire_resetn,

			/////////////////////////////////////////////////////////////
			//axi lite ports
			/////////////////////////////////////////////////////////////

			//axi4lite slaver signals
			input wire [31 : 0] S_AXI_AWADDR,
			input wire [2 : 0] S_AXI_AWPROT,
			input wire  S_AXI_AWVALID,
			output wire  S_AXI_AWREADY,
			input wire [31 : 0] S_AXI_WDATA,
			input wire [(32/8)-1 : 0] S_AXI_WSTRB,
			input wire  S_AXI_WVALID,
			output wire  S_AXI_WREADY,
			output wire [1 : 0] S_AXI_BRESP,
			output wire  S_AXI_BVALID,
			input wire  S_AXI_BREADY,
			input wire [31 : 0] S_AXI_ARADDR,
			input wire [2 : 0] S_AXI_ARPROT,
			input wire  S_AXI_ARVALID,
			output wire  S_AXI_ARREADY,
			output wire [31 : 0] S_AXI_RDATA,
			output wire [1 : 0] S_AXI_RRESP,
			output wire  S_AXI_RVALID,
			input wire  S_AXI_RREADY,

			/////////////////////////////////////////////////////////////
			//axi full ports
			/////////////////////////////////////////////////////////////

			//axi4full master signals
			output wire m00_axi_awid,
			output wire [31 : 0] m00_axi_awaddr,
			output wire [7 : 0] m00_axi_awlen,
			output wire [2 : 0] m00_axi_awsize,
			output wire [1 : 0] m00_axi_awburst,
			output wire  m00_axi_awlock,
			output wire [3 : 0] m00_axi_awcache,
			output wire [2 : 0] m00_axi_awprot,
			output wire [3 : 0] m00_axi_awqos,
			output wire  m00_axi_awvalid,
			input wire  m00_axi_awready,
			output wire [31 : 0] m00_axi_wdata,
			output wire [32/8-1 : 0] m00_axi_wstrb,
			output wire  m00_axi_wlast,
			output wire  m00_axi_wvalid,
			input wire  m00_axi_wready,
			input wire  m00_axi_bid,
			input wire  [1 : 0] m00_axi_bresp,
			input wire  m00_axi_bvalid,
			output wire m00_axi_bready,
			output wire m00_axi_arid,
			output wire [31 : 0] m00_axi_araddr,
			output wire [7 : 0] m00_axi_arlen,
			output wire [2 : 0] m00_axi_arsize,
			output wire [1 : 0] m00_axi_arburst,
			output wire  m00_axi_arlock,
			output wire [3 : 0] m00_axi_arcache,
			output wire [2 : 0] m00_axi_arprot,
			output wire [3 : 0] m00_axi_arqos,
			output wire  m00_axi_arvalid,
			input wire  m00_axi_arready,
			input wire  m00_axi_rid,
			input wire [31 : 0] m00_axi_rdata,
			input wire [1 : 0] m00_axi_rresp,
			input wire  m00_axi_rlast,
			input wire  m00_axi_rvalid,
			output wire  m00_axi_rready,

			output wire[31:0] o_wire_rasterizer_i_wire_test_point,
    		output wire       o_wire_rasterizer_i_wire_valid,
    		output wire[31:0] o_wire_rasterizer_i_wire_point1,
    		output wire[31:0] o_wire_rasterizer_i_wire_point2,
    		output wire[31:0] o_wire_rasterizer_i_wire_point3,
    		output wire[31:0] o_wire_rasterizer_i_wire_yes_color,
    		output wire[31:0] o_wire_rasterizer_i_wire_no_color,
    		output wire       o_wire_rasterizer_o_wire_valid,
    		output wire[31:0] o_wire_rasterizer_o_wire_color
		);


		//////////////////////////////////////////////////////////////////////////////
		//controller
		///////////////////////////////////////////////////////////////////////////////

		wire controller_o_wire_gpuinfo_resetn;
		wire [31 : 0] controller_o_wire_gpuinfo_opcode;
		wire [31 : 0] controller_i_wire_gpuinfo_state;
		wire [31 : 0] controller_i_wire_gpuinfo_return;

		wire controller_o_wire_memcpy_resetn;
		wire [31 : 0] controller_o_wire_memcpy_src_address;
		wire [31 : 0] controller_o_wire_memcpy_dst_address;
		wire [31 : 0] controller_o_wire_memcpy_data_length;
		wire [31 : 0] controller_i_wire_memcpy_state;

		wire controller_o_wire_renderer_resetn;
		wire [31 : 0] controller_o_wire_renderer_src_address;
		wire [31 : 0] controller_o_wire_renderer_src_width;
		wire [31 : 0] controller_o_wire_renderer_src_x_count;
		wire [31 : 0] controller_o_wire_renderer_src_y_count;

		wire [31 : 0] controller_o_wire_renderer_dst_address;
		wire [31 : 0] controller_o_wire_renderer_dst_width;

		wire [31 : 0] controller_o_wire_color_format;
		wire [31 : 0] controller_o_wire_renderer_blend;
		wire [31 : 0] controller_i_wire_renderer_state;

		wire[31:0] controller_o_wire_renderer_mode;
		wire[31:0] controller_o_wire_renderer_point1;
    	wire[31:0] controller_o_wire_renderer_point2;
    	wire[31:0] controller_o_wire_renderer_point3;
    	wire[31:0] controller_o_wire_renderer_yes_color;
    	wire[31:0] controller_o_wire_renderer_no_color;

		wire 	   controller_o_wire_colorconvert_resetn;
		wire[31:0] controller_o_wire_colorconvert_src_address;
		wire[31:0] controller_o_wire_colorconvert_dst_address;
		wire[31:0] controller_o_wire_colorconvert_data_length;
		wire[31:0] controller_o_wire_colorconvert_data_iomode;
		wire[31:0] controller_i_wire_colorconvert_state;



		painterengine_gpu_controller gpu_controller(
			//axi4lite signals
			.S_AXI_ACLK(S_AXI_ACLK),
		    .S_AXI_ARESETN(i_wire_resetn),
		    .S_AXI_AWADDR(S_AXI_AWADDR),
			.S_AXI_AWPROT(S_AXI_AWPROT),
		    .S_AXI_AWVALID(S_AXI_AWVALID),
		    .S_AXI_AWREADY(S_AXI_AWREADY),
		    .S_AXI_WDATA(S_AXI_WDATA),
		    .S_AXI_WSTRB(S_AXI_WSTRB),
			.S_AXI_WVALID(S_AXI_WVALID),
			.S_AXI_WREADY(S_AXI_WREADY),
			.S_AXI_BRESP(S_AXI_BRESP),
			.S_AXI_BVALID(S_AXI_BVALID),
			.S_AXI_BREADY(S_AXI_BREADY),
			.S_AXI_ARADDR(S_AXI_ARADDR),
			.S_AXI_ARPROT(S_AXI_ARPROT),
			.S_AXI_ARVALID(S_AXI_ARVALID),
			.S_AXI_ARREADY(S_AXI_ARREADY),
			.S_AXI_RDATA(S_AXI_RDATA),
			.S_AXI_RRESP(S_AXI_RRESP),
			.S_AXI_RVALID(S_AXI_RVALID),
			.S_AXI_RREADY(S_AXI_RREADY),

			//gpuinfo
			.o_wire_gpuinfo_resetn(controller_o_wire_gpuinfo_resetn),
			.o_wire_gpuinfo_opcode(controller_o_wire_gpuinfo_opcode),
			.i_wire_gpuinfo_state(controller_i_wire_gpuinfo_state),
			.i_wire_gpuinfo_return(controller_i_wire_gpuinfo_return),

			//memcpy
			.o_wire_memcpy_resetn(controller_o_wire_memcpy_resetn),
			.o_wire_memcpy_src_address(controller_o_wire_memcpy_src_address),
			.o_wire_memcpy_dst_address(controller_o_wire_memcpy_dst_address),
			.o_wire_memcpy_data_length(controller_o_wire_memcpy_data_length),
			.i_wire_memcpy_state(controller_i_wire_memcpy_state),

			//renderer
			.o_wire_renderer_resetn(controller_o_wire_renderer_resetn),
			.o_wire_renderer_src_address(controller_o_wire_renderer_src_address),
			.o_wire_renderer_src_width(controller_o_wire_renderer_src_width),
			.o_wire_renderer_src_x_count(controller_o_wire_renderer_src_x_count),
			.o_wire_renderer_src_y_count(controller_o_wire_renderer_src_y_count),
			.o_wire_renderer_dst_address(controller_o_wire_renderer_dst_address),
			.o_wire_renderer_dst_width(controller_o_wire_renderer_dst_width),
			.o_wire_renderer_color_format(controller_o_wire_color_format),
			.o_wire_renderer_blend(controller_o_wire_renderer_blend),
			.i_wire_renderer_state(controller_i_wire_renderer_state),
			.o_wire_renderer_mode(controller_o_wire_renderer_mode),
			.o_wire_renderer_point1(controller_o_wire_renderer_point1),
    		.o_wire_renderer_point2(controller_o_wire_renderer_point2),
    		.o_wire_renderer_point3(controller_o_wire_renderer_point3),
    		.o_wire_renderer_yes_color(controller_o_wire_renderer_yes_color),
    		.o_wire_renderer_no_color(controller_o_wire_renderer_no_color),

			.o_wire_colorconvert_resetn(controller_o_wire_colorconvert_resetn),
			.o_wire_colorconvert_src_address(controller_o_wire_colorconvert_src_address),
			.o_wire_colorconvert_dst_address(controller_o_wire_colorconvert_dst_address),
			.o_wire_colorconvert_data_length(controller_o_wire_colorconvert_data_length),
			.o_wire_colorconvert_data_iomode(controller_o_wire_colorconvert_data_iomode),
			.i_wire_colorconvert_state(controller_i_wire_colorconvert_state)
		);

		///////////////////////////////////////////////////////////////////////////////
		//gpuinfo
		///////////////////////////////////////////////////////////////////////////////
		//gpuinfo pins
		wire gpuinfo_i_wire_resetn;
		wire [31 : 0] gpuinfo_i_wire_opcode;
		wire [31 : 0] gpuinfo_o_wire_state;
		wire [31 : 0] gpuinfo_o_wire_return;
	
		painterengine_gpu_gpuinfo gpu_gpuinfo0(
			//clock
			.i_wire_clock(i_wire_clock),
			//resetn
			.i_wire_resetn(gpuinfo_i_wire_resetn),
			//tick resetn
			.i_wire_tick_resetn(i_wire_resetn),
			//opcode
			.i_wire_opcode(gpuinfo_i_wire_opcode),
			//state
			.o_wire_state(gpuinfo_o_wire_state),
			//return
			.o_wire_return(gpuinfo_o_wire_return)
		);
		assign gpuinfo_i_wire_resetn=controller_o_wire_gpuinfo_resetn;
		assign gpuinfo_i_wire_opcode=controller_o_wire_gpuinfo_opcode;
		assign controller_i_wire_gpuinfo_state=gpuinfo_o_wire_state;
		assign controller_i_wire_gpuinfo_return=gpuinfo_o_wire_return;


		///////////////////////////////////////////////////////////////////////////////
		//memcpy
		///////////////////////////////////////////////////////////////////////////////

		//gpu memcpy pins
		wire memcpy_i_wire_resetn;
		wire [31:0] memcpy_i_wire_source_address;
		wire [31:0] memcpy_i_wire_dest_address;
		wire [31:0] memcpy_i_wire_length;//bytes count

		wire memcpy_o_wire_fifo_resetn;

		wire memcpy_o_wire_dma_reader_resetn;
		wire [31:0] memcpy_o_wire_dma_reader_address;
		wire [31:0] memcpy_o_wire_dma_reader_length;
		wire memcpy_i_wire_dma_reader_done;
		wire memcpy_i_wire_dma_reader_error;

		wire memcpy_o_wire_dma_writer_resetn;
		wire [31:0] memcpy_o_wire_dma_writer_address;
		wire [31:0] memcpy_o_wire_dma_writer_length;
		wire memcpy_i_wire_dma_writer_done;
		wire memcpy_i_wire_dma_writer_error;

		wire [31 : 0] memcpy_o_wire_memcpy_state;

		painterengine_gpu_memcpy gpu_memcpy(
			//clock
			.i_wire_clock(i_wire_clock),
			//resetn
			.i_wire_resetn(memcpy_i_wire_resetn),
			//source address
			.i_wire_source_address(memcpy_i_wire_source_address),
			//dest address
			.i_wire_dest_address(memcpy_i_wire_dest_address),
			//length
			.i_wire_length(memcpy_i_wire_length),
			//fifo
			.o_wire_fifo_resetn(memcpy_o_wire_fifo_resetn),
			//reader
			.o_wire_dma_reader_resetn(memcpy_o_wire_dma_reader_resetn),
			.o_wire_dma_reader_address(memcpy_o_wire_dma_reader_address),
			.o_wire_dma_reader_length(memcpy_o_wire_dma_reader_length),
			.i_wire_dma_reader_done(memcpy_i_wire_dma_reader_done),
			.i_wire_dma_reader_error(memcpy_i_wire_dma_reader_error),
			//writer
			.o_wire_dma_writer_resetn(memcpy_o_wire_dma_writer_resetn),
			.o_wire_dma_writer_address(memcpy_o_wire_dma_writer_address),
			.o_wire_dma_writer_length(memcpy_o_wire_dma_writer_length),
			.i_wire_dma_writer_done(memcpy_i_wire_dma_writer_done),
			.i_wire_dma_writer_error(memcpy_i_wire_dma_writer_error),

			//state
			.o_wire_state(memcpy_o_wire_memcpy_state)
		);

		assign memcpy_i_wire_resetn=controller_o_wire_memcpy_resetn;
		assign memcpy_i_wire_source_address=controller_o_wire_memcpy_src_address;
		assign memcpy_i_wire_dest_address=controller_o_wire_memcpy_dst_address;
		assign memcpy_i_wire_length=controller_o_wire_memcpy_data_length;
		assign controller_i_wire_memcpy_state=memcpy_o_wire_memcpy_state;

		//////////////////////////////////////////////////////////////////////////////
		//colorconvert
		//////////////////////////////////////////////////////////////////////////////
		wire colorconvert_i_wire_resetn;
		wire [31:0] colorconvert_i_wire_source_address;
		wire [31:0] colorconvert_i_wire_dest_address;
		wire [31:0] colorconvert_i_wire_length;
		//////////////////////////////////////////////
		//fifo
		wire colorconvert_o_wire_fifo_resetn;
		
		//////////////////////////////////////////////
		//dma reader
		wire colorconvert_o_wire_dma_reader_resetn;
		wire [31:0] colorconvert_o_wire_dma_reader_address;
		wire [31:0] colorconvert_o_wire_dma_reader_length;
		wire colorconvert_i_wire_dma_reader_done;
		wire colorconvert_i_wire_dma_reader_error;
		//////////////////////////////////////////////

		//dma writer
		wire colorconvert_o_wire_dma_writer_resetn;
		wire [31:0] colorconvert_o_wire_dma_writer_address;
		wire [31:0] colorconvert_o_wire_dma_writer_length;
		wire colorconvert_i_wire_dma_writer_done;
		wire colorconvert_i_wire_dma_writer_error;
		//////////////////////////////////////////////
		wire[31:0] 	colorconvert_o_wire_state;

		painterengine_gpu_colorconvert gpu_colorconvert(
			.i_wire_clock(i_wire_clock),
			.i_wire_resetn(colorconvert_i_wire_resetn),
			.i_wire_source_address(colorconvert_i_wire_source_address),
			.i_wire_dest_address(colorconvert_i_wire_dest_address),
			.i_wire_length(colorconvert_i_wire_length),
			//////////////////////////////////////////////
			//fifo
			.o_wire_fifo_resetn(colorconvert_o_wire_fifo_resetn),
			
			//////////////////////////////////////////////
			//dma reader
			.o_wire_dma_reader_resetn(colorconvert_o_wire_dma_reader_resetn),
			.o_wire_dma_reader_address(colorconvert_o_wire_dma_reader_address),
			.o_wire_dma_reader_length(colorconvert_o_wire_dma_reader_length),
			.i_wire_dma_reader_done(colorconvert_i_wire_dma_reader_done),
			.i_wire_dma_reader_error(colorconvert_i_wire_dma_reader_error),
			//////////////////////////////////////////////

			//dma writer
			.o_wire_dma_writer_resetn(colorconvert_o_wire_dma_writer_resetn),
			.o_wire_dma_writer_address(colorconvert_o_wire_dma_writer_address),
			.o_wire_dma_writer_length(colorconvert_o_wire_dma_writer_length),
			.i_wire_dma_writer_done(colorconvert_i_wire_dma_writer_done),
			.i_wire_dma_writer_error(colorconvert_i_wire_dma_writer_error),
			//////////////////////////////////////////////

			.o_wire_state(colorconvert_o_wire_state)
		);
		assign colorconvert_i_wire_resetn=controller_o_wire_colorconvert_resetn;
		assign colorconvert_i_wire_source_address=controller_o_wire_colorconvert_src_address;
		assign colorconvert_i_wire_dest_address=controller_o_wire_colorconvert_dst_address;
		assign colorconvert_i_wire_length=controller_o_wire_colorconvert_data_length;
		assign controller_i_wire_colorconvert_state=colorconvert_o_wire_state;



		///////////////////////////////////////////////////////////////////////////////
		//renderer
		///////////////////////////////////////////////////////////////////////////////
    	wire 		renderer_i_wire_resetn;
    	wire[31:0] 	renderer_i_wire_src_frame_buffer_address;
    	wire[31:0] 	renderer_i_wire_dst_frame_buffer_address;
    	wire[31:0] 	renderer_i_wire_src_frame_buffer_width;
    	wire[31:0] 	renderer_i_wire_dst_frame_buffer_width;
    	wire[31:0] 	renderer_i_wire_render_frame_buffer_xcount;
    	wire[31:0] 	renderer_i_wire_render_frame_buffer_ycount;
    	wire[31:0] 	renderer_o_wire_dma_reader_address;
    	wire[31:0] 	renderer_o_wire_dma_reader_length;
    	wire 		renderer_o_wire_dma_reader1_resetn;
		wire 		renderer_o_wire_dma_reader2_resetn;
    	wire 		renderer_i_wire_dma_reader_done;
    	wire 		renderer_i_wire_dma_reader_error;
    	wire[31:0] 	renderer_o_wire_dma_writer_address;
    	wire[31:0] 	renderer_o_wire_dma_writer_length;
    	wire 		renderer_o_wire_writer_resetn;
    	wire 		renderer_i_wire_dma_writer_done;
    	wire 		renderer_i_wire_writer_error;
    	wire 		renderer_o_wire_fifo1_resetn;
    	wire 		renderer_o_wire_fifo2_resetn;
    	wire[31:0] 	renderer_o_wire_state;

		wire       renderer_i_wire_rasterizer_mode;
    	wire       renderer_o_wire_rasterizer_resetn;
    	wire[31:0] renderer_o_wire_rasterizer_xy;
    	wire       renderer_o_wire_rasterizer_valid;



       painterengine_gpu_renderer gpu_renderer(
    		.i_wire_clock(i_wire_clock),
    		.i_wire_resetn(renderer_i_wire_resetn),

    		.i_wire_src_frame_buffer_address(renderer_i_wire_src_frame_buffer_address),
    		.i_wire_dst_frame_buffer_address(renderer_i_wire_dst_frame_buffer_address),
    		.i_wire_src_frame_buffer_width(renderer_i_wire_src_frame_buffer_width),
    		.i_wire_dst_frame_buffer_width(renderer_i_wire_dst_frame_buffer_width),
    		.i_wire_render_frame_buffer_xcount(renderer_i_wire_render_frame_buffer_xcount),
    		.i_wire_render_frame_buffer_ycount(renderer_i_wire_render_frame_buffer_ycount),

    		//reader controller
			.o_wire_reader1_resetn(renderer_o_wire_dma_reader1_resetn),
			.o_wire_reader2_resetn(renderer_o_wire_dma_reader2_resetn),
    		.o_wire_reader_address(renderer_o_wire_dma_reader_address),
    		.o_wire_reader_length(renderer_o_wire_dma_reader_length),

    		.i_wire_reader_done(renderer_i_wire_dma_reader_done),
    		.i_wire_reader_error(renderer_i_wire_dma_reader_error),

    		//writer controller
    		.o_wire_writer_address(renderer_o_wire_dma_writer_address),
    		.o_wire_writer_length(renderer_o_wire_dma_writer_length),
    		.o_wire_writer_resetn(renderer_o_wire_writer_resetn),
    		.i_wire_writer_done(renderer_i_wire_dma_writer_done),
    		.i_wire_writer_error(renderer_i_wire_writer_error),

    		.o_wire_fifo1_resetn(renderer_o_wire_fifo1_resetn),
    		.o_wire_fifo2_resetn(renderer_o_wire_fifo2_resetn),

			//rasterize
			.i_wire_rasterizer_mode(renderer_i_wire_rasterizer_mode),
			.o_wire_rasterizer_resetn(renderer_o_wire_rasterizer_resetn),
			.o_wire_rasterizer_xy(renderer_o_wire_rasterizer_xy),
			.o_wire_rasterizer_valid(renderer_o_wire_rasterizer_valid),

    		//state
    		.o_wire_state(renderer_o_wire_state)
			);

		assign renderer_i_wire_resetn=controller_o_wire_renderer_resetn;
		assign renderer_i_wire_src_frame_buffer_address=controller_o_wire_renderer_src_address;
		assign renderer_i_wire_dst_frame_buffer_address=controller_o_wire_renderer_dst_address;
		assign renderer_i_wire_src_frame_buffer_width=controller_o_wire_renderer_src_width;
		assign renderer_i_wire_dst_frame_buffer_width=controller_o_wire_renderer_dst_width;
		assign renderer_i_wire_render_frame_buffer_xcount=controller_o_wire_renderer_src_x_count;
		assign renderer_i_wire_render_frame_buffer_ycount=controller_o_wire_renderer_src_y_count;
		assign controller_i_wire_renderer_state=renderer_o_wire_state;

		assign renderer_i_wire_rasterizer_mode=controller_o_wire_renderer_mode[0];

		

		
		///////////////////////////////////////////////////////////////////////////////
		//dma reader
		///////////////////////////////////////////////////////////////////////////////

		wire dma_reader_i_wire_resetn;
		wire dma_reader_o_wire_done;

		wire [31:0] dma_reader_i_wire_address0;
		wire [31:0] dma_reader_i_wire_address1;
		wire [31:0] dma_reader_i_wire_address2;
		wire [31:0] dma_reader_i_wire_address3;

		wire [31:0] dma_reader_i_wire_length0;
		wire [31:0] dma_reader_i_wire_length1;
		wire [31:0] dma_reader_i_wire_length2;
		wire [31:0] dma_reader_i_wire_length3;

		wire dma_reader_i_wire_router0;
		wire dma_reader_i_wire_router1;
		wire dma_reader_i_wire_router2;
		wire dma_reader_i_wire_router3;

		wire [31:0] dma_reader_o_wire_data0;
		wire [31:0] dma_reader_o_wire_data1;
		wire [31:0] dma_reader_o_wire_data2;
		wire [31:0] dma_reader_o_wire_data3;

		wire dma_reader_o_wire_data_valid0;
		wire dma_reader_o_wire_data_valid1;
		wire dma_reader_o_wire_data_valid2;
		wire dma_reader_o_wire_data_valid3;

		wire dma_reader_i_wire_data_next0;
		wire dma_reader_i_wire_data_next1;
		wire dma_reader_i_wire_data_next2;
		wire dma_reader_i_wire_data_next3;

		wire dma_reader_o_wire_error;


		painterengine_gpu_dma_reader dma_reader(
		//input clk
		.i_wire_clock(i_wire_clock),
		.i_wire_resetn(dma_reader_i_wire_resetn),
		.o_wire_done(dma_reader_o_wire_done),

		.i_wire_address({dma_reader_i_wire_address3,dma_reader_i_wire_address2,dma_reader_i_wire_address1,dma_reader_i_wire_address0}),
		.i_wire_length({dma_reader_i_wire_length3,dma_reader_i_wire_length2,dma_reader_i_wire_length1,dma_reader_i_wire_length0}),
		.i_wire_router({dma_reader_i_wire_router3,dma_reader_i_wire_router2,dma_reader_i_wire_router1,dma_reader_i_wire_router0}),
		.o_wire_data({dma_reader_o_wire_data3,dma_reader_o_wire_data2,dma_reader_o_wire_data1,dma_reader_o_wire_data0}),
		.o_wire_data_valid({dma_reader_o_wire_data_valid3,dma_reader_o_wire_data_valid2,dma_reader_o_wire_data_valid1,dma_reader_o_wire_data_valid0}),
		.i_wire_data_next({dma_reader_i_wire_data_next3,dma_reader_i_wire_data_next2,dma_reader_i_wire_data_next1,dma_reader_i_wire_data_next0}),

		.o_wire_error(dma_reader_o_wire_error),

		//AXI full ports
		.o_wire_M_AXI_ARID(m00_axi_arid),
		.o_wire_M_AXI_ARADDR(m00_axi_araddr),
		.o_wire_M_AXI_ARLEN(m00_axi_arlen),
		.o_wire_M_AXI_ARSIZE(m00_axi_arsize),
		.o_wire_M_AXI_ARBURST(m00_axi_arburst),
		.o_wire_M_AXI_ARLOCK(m00_axi_arlock),
		.o_wire_M_AXI_ARCACHE(m00_axi_arcache),
		.o_wire_M_AXI_ARPROT(m00_axi_arprot),
		.o_wire_M_AXI_ARQOS(m00_axi_arqos),
		.o_wire_M_AXI_ARVALID(m00_axi_arvalid),
		.i_wire_M_AXI_ARREADY(m00_axi_arready),
		.i_wire_M_AXI_RID(m00_axi_rid),
		.i_wire_M_AXI_RDATA(m00_axi_rdata),
		.i_wire_M_AXI_RRESP(m00_axi_rresp),
		.i_wire_M_AXI_RLAST(m00_axi_rlast),
		.i_wire_M_AXI_RVALID(m00_axi_rvalid),
		.o_wire_M_AXI_RREADY(m00_axi_rready)
		);

		assign memcpy_i_wire_dma_reader_done=dma_reader_o_wire_done;
		assign renderer_i_wire_dma_reader_done=dma_reader_o_wire_done;
		assign colorconvert_i_wire_dma_reader_done=dma_reader_o_wire_done;

		assign dma_reader_i_wire_resetn=i_wire_resetn&&(dma_reader_i_wire_router0|dma_reader_i_wire_router1|dma_reader_i_wire_router2|dma_reader_i_wire_router3);
		assign dma_reader_i_wire_address0=colorconvert_o_wire_dma_reader_address;
		assign dma_reader_i_wire_address1=memcpy_o_wire_dma_reader_address;
		assign dma_reader_i_wire_address2=renderer_o_wire_dma_reader_address;
		assign dma_reader_i_wire_address3=renderer_o_wire_dma_reader_address;

		assign dma_reader_i_wire_length0=colorconvert_o_wire_dma_reader_length;
		assign dma_reader_i_wire_length1=memcpy_o_wire_dma_reader_length;
		assign dma_reader_i_wire_length2=renderer_o_wire_dma_reader_length;
		assign dma_reader_i_wire_length3=renderer_o_wire_dma_reader_length;

		assign dma_reader_i_wire_router0=colorconvert_o_wire_dma_reader_resetn;
		assign dma_reader_i_wire_router1=memcpy_o_wire_dma_reader_resetn;
		assign dma_reader_i_wire_router2=renderer_o_wire_dma_reader1_resetn;
		assign dma_reader_i_wire_router3=renderer_o_wire_dma_reader2_resetn;

		assign memcpy_i_wire_dma_reader_error=dma_reader_o_wire_error;
		assign renderer_i_wire_dma_reader_error=dma_reader_o_wire_error;
		assign colorconvert_i_wire_dma_reader_error=dma_reader_o_wire_error;


		
		///////////////////////////////////////////////////////////////////////////////
		//fifo_memcpy
		///////////////////////////////////////////////////////////////////////////////
		//fifo_memcpy pins

		wire fifo_memcpy_i_wire_resetn;
		wire fifo_memcpy_i_wire_write;
		wire fifo_memcpy_i_wire_read;


		wire [31 : 0] fifo_memcpy_i_wire_data_in;
		wire [31 : 0] fifo_memcpy_o_wire_data_out;
		wire fifo_memcpy_o_wire_almost_full;
		wire fifo_memcpy_o_wire_full;
		wire fifo_memcpy_o_wire_almost_empty;
		wire fifo_memcpy_o_wire_empty;

		painterengine_gpu_fifo fifo_memcpy(
			.i_wire_write_clock(i_wire_clock),
			.i_wire_read_clock(i_wire_clock),

			.i_wire_resetn(fifo_memcpy_i_wire_resetn),

			.i_wire_write(fifo_memcpy_i_wire_write),
			.i_wire_read(fifo_memcpy_i_wire_read),

			.i_wire_data_in(fifo_memcpy_i_wire_data_in),
			.o_wire_data_out(fifo_memcpy_o_wire_data_out),

			.o_wire_almost_full(fifo_memcpy_o_wire_almost_full),
			.o_wire_full(fifo_memcpy_o_wire_full),
			
			.o_wire_almost_empty(fifo_memcpy_o_wire_almost_empty),
			.o_wire_empty(fifo_memcpy_o_wire_empty),
			.o_wire_data_count(),
			.o_wire_empty_count()
		);

		assign fifo_memcpy_i_wire_resetn=memcpy_o_wire_fifo_resetn;
		assign fifo_memcpy_i_wire_write=dma_reader_o_wire_data_valid1;
		assign fifo_memcpy_i_wire_data_in=dma_reader_o_wire_data1;
		assign dma_reader_i_wire_data_next1=!fifo_memcpy_o_wire_full;

		///////////////////////////////////////////////////////////////////////////////
		//argb2rgb
		///////////////////////////////////////////////////////////////////////////////
        wire argb2rgb_i_wire_resetn;
        wire [31:0] argb2rgb_i_wire_color;
        wire argb2rgb_i_wire_valid;
        wire[1:0] argb2rgb_i_wire_iargb_mode;//0:ARGB, 1:ABGR, 2:RGBA, 3:BGRA
        wire  argb2rgb_i_wire_oargb_mode;//0:RGB, 1:BGR
        wire [31:0] argb2rgb_o_wire_rgb;
        wire argb2rgb_o_wire_valid;
		painterengine_gpu_argb2rgb argb2rgb(
            .i_wire_clock(i_wire_clock),
            .i_wire_resetn(argb2rgb_i_wire_resetn),
            .i_wire_color(argb2rgb_i_wire_color),
            .i_wire_valid(argb2rgb_i_wire_valid),
            .i_wire_iargb_mode(argb2rgb_i_wire_iargb_mode),//0:ARGB, 1:ABGR, 2:RGBA, 3:BGRA
            .i_wire_oargb_mode(argb2rgb_i_wire_oargb_mode),//0:RGB, 1:BGR
            .o_wire_rgb(argb2rgb_o_wire_rgb),
            .o_wire_valid(argb2rgb_o_wire_valid)
        );
		assign argb2rgb_i_wire_resetn=colorconvert_o_wire_fifo_resetn;
		assign argb2rgb_i_wire_color=dma_reader_o_wire_data0;
		assign argb2rgb_i_wire_valid=dma_reader_o_wire_data_valid0;
		assign argb2rgb_i_wire_iargb_mode=controller_o_wire_color_format[1:0];
		assign argb2rgb_i_wire_oargb_mode=controller_o_wire_color_format[2];
		assign dma_reader_i_wire_data_next0=colorconvert_o_wire_dma_reader_resetn;


		///////////////////////////////////////////////////////////////////////////////
		//fifo_colorconvert
		///////////////////////////////////////////////////////////////////////////////
		//fifo_colorconvert pins

		wire fifo_colorconvert_i_wire_resetn;
		wire fifo_colorconvert_i_wire_write;
		wire fifo_colorconvert_i_wire_read;


		wire [31 : 0] fifo_colorconvert_i_wire_data_in;
		wire [31 : 0] fifo_colorconvert_o_wire_data_out;
		wire fifo_colorconvert_o_wire_almost_full;
		wire fifo_colorconvert_o_wire_full;
		wire fifo_colorconvert_o_wire_almost_empty;
		wire fifo_colorconvert_o_wire_empty;

		painterengine_gpu_fifo fifo_colorconvert(
			.i_wire_write_clock(i_wire_clock),
			.i_wire_read_clock(i_wire_clock),

			.i_wire_resetn(fifo_colorconvert_i_wire_resetn),

			.i_wire_write(fifo_colorconvert_i_wire_write),
			.i_wire_read(fifo_colorconvert_i_wire_read),

			.i_wire_data_in(fifo_colorconvert_i_wire_data_in),
			.o_wire_data_out(fifo_colorconvert_o_wire_data_out),

			.o_wire_almost_full(fifo_colorconvert_o_wire_almost_full),
			.o_wire_full(fifo_colorconvert_o_wire_full),
			
			.o_wire_almost_empty(fifo_colorconvert_o_wire_almost_empty),
			.o_wire_empty(fifo_colorconvert_o_wire_empty),
			.o_wire_data_count(),
			.o_wire_empty_count()
		);

		assign fifo_colorconvert_i_wire_resetn=colorconvert_o_wire_fifo_resetn;
		assign fifo_colorconvert_i_wire_write=argb2rgb_o_wire_valid;
		assign fifo_colorconvert_i_wire_data_in=argb2rgb_o_wire_rgb;

		///////////////////////////////////////////////////////////////////////////////
		//painterengine_gpu_rasterizer
		///////////////////////////////////////////////////////////////////////////////
		wire       rasterizer_i_wire_clock;
    	wire       rasterizer_i_wire_resetn;
    	wire[31:0] rasterizer_i_wire_test_point;
    	wire       rasterizer_i_wire_valid;
    	wire[31:0] rasterizer_i_wire_point1;
    	wire[31:0] rasterizer_i_wire_point2;
    	wire[31:0] rasterizer_i_wire_point3;
    	wire[31:0] rasterizer_i_wire_yes_color;
    	wire[31:0] rasterizer_i_wire_no_color;
    	wire       rasterizer_o_wire_valid;
    	wire[31:0] rasterizer_o_wire_color;

		painterengine_gpu_rasterizer gpu_rasterizer(
			.i_wire_clock(i_wire_clock),
    		.i_wire_resetn(rasterizer_i_wire_resetn),
    		.i_wire_test_point(rasterizer_i_wire_test_point),
    		.i_wire_valid(rasterizer_i_wire_valid),
    		.i_wire_point1(rasterizer_i_wire_point1),
    		.i_wire_point2(rasterizer_i_wire_point2),
    		.i_wire_point3(rasterizer_i_wire_point3),
    		.i_wire_yes_color(rasterizer_i_wire_yes_color),
    		.i_wire_no_color(rasterizer_i_wire_no_color),
    		.o_wire_valid(rasterizer_o_wire_valid),
    		.o_wire_color(rasterizer_o_wire_color)
		);
		assign rasterizer_i_wire_resetn=renderer_o_wire_rasterizer_resetn;
		assign rasterizer_i_wire_test_point=renderer_o_wire_rasterizer_xy;
		assign rasterizer_i_wire_valid=renderer_o_wire_rasterizer_valid;
		assign rasterizer_i_wire_point1=controller_o_wire_renderer_point1;
		assign rasterizer_i_wire_point2=controller_o_wire_renderer_point2;
		assign rasterizer_i_wire_point3=controller_o_wire_renderer_point3;
		assign rasterizer_i_wire_yes_color=controller_o_wire_renderer_yes_color;
		assign rasterizer_i_wire_no_color=controller_o_wire_renderer_no_color;

		assign o_wire_rasterizer_i_wire_test_point=renderer_o_wire_rasterizer_xy;
    	assign o_wire_rasterizer_i_wire_valid=renderer_o_wire_rasterizer_valid;
    	assign o_wire_rasterizer_i_wire_point1=controller_o_wire_renderer_point1;
    	assign o_wire_rasterizer_i_wire_point2=controller_o_wire_renderer_point2;
    	assign o_wire_rasterizer_i_wire_point3=controller_o_wire_renderer_point3;
    	assign o_wire_rasterizer_i_wire_yes_color=controller_o_wire_renderer_yes_color;
    	assign o_wire_rasterizer_i_wire_no_color=controller_o_wire_renderer_no_color;
    	assign o_wire_rasterizer_o_wire_valid=rasterizer_o_wire_valid;
    	assign o_wire_rasterizer_o_wire_color=rasterizer_o_wire_color;

		///////////////////////////////////////////////////////////////////////////////
		//fifo_render1 2
		///////////////////////////////////////////////////////////////////////////////
		wire fifo_render1_i_wire_resetn;
		wire fifo_render1_i_wire_write;
		wire fifo_render1_i_wire_read;


		wire [31 : 0] fifo_render1_i_wire_data_in;
		wire [31 : 0] fifo_render1_o_wire_data_out;
		wire fifo_render1_o_wire_almost_full;
		wire fifo_render1_o_wire_full;
		wire fifo_render1_o_wire_almost_empty;
		wire fifo_render1_o_wire_empty;

		painterengine_gpu_fifo fifo_render1(
			.i_wire_write_clock(i_wire_clock),
			.i_wire_read_clock(i_wire_clock),

			.i_wire_resetn(fifo_render1_i_wire_resetn),

			.i_wire_write(fifo_render1_i_wire_write),
			.i_wire_read(fifo_render1_i_wire_read),

			.i_wire_data_in(fifo_render1_i_wire_data_in),
			.o_wire_data_out(fifo_render1_o_wire_data_out),

			.o_wire_almost_full(fifo_render1_o_wire_almost_full),
			.o_wire_full(fifo_render1_o_wire_full),
			
			.o_wire_almost_empty(fifo_render1_o_wire_almost_empty),
			.o_wire_empty(fifo_render1_o_wire_empty),
			.o_wire_data_count(),
			.o_wire_empty_count()
		);
		
		assign fifo_render1_i_wire_resetn=renderer_o_wire_fifo1_resetn;
		assign fifo_render1_i_wire_write=controller_o_wire_renderer_mode[0]?rasterizer_o_wire_valid:dma_reader_o_wire_data_valid2;
		assign fifo_render1_i_wire_data_in=controller_o_wire_renderer_mode[0]?rasterizer_o_wire_color:dma_reader_o_wire_data2;
		assign dma_reader_i_wire_data_next2=!fifo_render1_o_wire_full;


		wire fifo_render2_i_wire_resetn;
		wire fifo_render2_i_wire_write;
		wire fifo_render2_i_wire_read;


		wire [31 : 0] fifo_render2_i_wire_data_in;
		wire [31 : 0] fifo_render2_o_wire_data_out;
		wire fifo_render2_o_wire_almost_full;
		wire fifo_render2_o_wire_full;
		wire fifo_render2_o_wire_almost_empty;
		wire fifo_render2_o_wire_empty;

		painterengine_gpu_fifo fifo_render2(
			.i_wire_write_clock(i_wire_clock),
			.i_wire_read_clock(i_wire_clock),

			.i_wire_resetn(fifo_render2_i_wire_resetn),

			.i_wire_write(fifo_render2_i_wire_write),
			.i_wire_read(fifo_render2_i_wire_read),

			.i_wire_data_in(fifo_render2_i_wire_data_in),
			.o_wire_data_out(fifo_render2_o_wire_data_out),

			.o_wire_almost_full(fifo_render2_o_wire_almost_full),
			.o_wire_full(fifo_render2_o_wire_full),
			
			.o_wire_almost_empty(fifo_render2_o_wire_almost_empty),
			.o_wire_empty(fifo_render2_o_wire_empty),
			.o_wire_data_count(),
			.o_wire_empty_count()
		);
		assign fifo_render2_i_wire_resetn=renderer_o_wire_fifo2_resetn;
		assign fifo_render2_i_wire_write=dma_reader_o_wire_data_valid3;
		assign fifo_render2_i_wire_data_in=dma_reader_o_wire_data3;
		assign dma_reader_i_wire_data_next3=!fifo_render2_o_wire_full;

		//////////////////////////////////////////////////////////////////////////////
		//alphablend
		//////////////////////////////////////////////////////////////////////////////
		wire blender_i_wire_argb_mode;
		wire blender_o_wire_fifo1_read;
		wire blender_o_wire_fifo2_read;
		wire[31:0] blender_i_wire_data1_in;
		wire[31:0] blender_i_wire_data2_in;
		wire[31:0] blender_i_wire_blend;
		wire[31:0] blender_o_wire_data_out;
		wire blender_o_wire_data_valid;
		wire blender_i_wire_fifo1_empty;
		wire blender_i_wire_fifo2_empty;
		painterengine_gpu_blender gpu_blender(
			.i_wire_clock(i_wire_clock),
			.i_wire_resetn(controller_o_wire_renderer_resetn),
		    .i_wire_argb_mode(blender_i_wire_argb_mode),
			.o_wire_fifo1_read(blender_o_wire_fifo1_read),
		    .o_wire_fifo2_read(blender_o_wire_fifo2_read),
			.i_wire_data1_in(blender_i_wire_data1_in),
		    .i_wire_data2_in(blender_i_wire_data2_in),
			.i_wire_blend(blender_i_wire_blend),
			.o_wire_data_out(blender_o_wire_data_out),
		    .o_wire_data_valid(blender_o_wire_data_valid),
			.i_wire_fifo1_empty(blender_i_wire_fifo1_empty),
		    .i_wire_fifo2_empty(blender_i_wire_fifo2_empty)
		);
		assign blender_i_wire_argb_mode=controller_o_wire_color_format[0];
		assign fifo_render1_i_wire_read=blender_o_wire_fifo1_read;
		assign fifo_render2_i_wire_read=blender_o_wire_fifo2_read;
		assign blender_i_wire_data1_in=fifo_render1_o_wire_data_out;
		assign blender_i_wire_data2_in=fifo_render2_o_wire_data_out;
		assign blender_i_wire_fifo1_empty=fifo_render1_o_wire_empty;
		assign blender_i_wire_fifo2_empty=fifo_render2_o_wire_empty;
		assign blender_i_wire_blend=controller_o_wire_renderer_blend;

		//////////////////////////////////////////////////////////////////////////////
		//fifo render3
		wire fifo_render3_i_wire_resetn;
		wire fifo_render3_i_wire_write;
		wire fifo_render3_i_wire_read;


		wire [31 : 0] fifo_render3_i_wire_data_in;
		wire [31 : 0] fifo_render3_o_wire_data_out;
		wire fifo_render3_o_wire_almost_full;
		wire fifo_render3_o_wire_full;
		wire fifo_render3_o_wire_almost_empty;
		wire fifo_render3_o_wire_empty;

		painterengine_gpu_fifo fifo_render3(
			.i_wire_write_clock(i_wire_clock),
			.i_wire_read_clock(i_wire_clock),

			.i_wire_resetn(fifo_render3_i_wire_resetn),

			.i_wire_write(fifo_render3_i_wire_write),
			.i_wire_read(fifo_render3_i_wire_read),

			.i_wire_data_in(fifo_render3_i_wire_data_in),
			.o_wire_data_out(fifo_render3_o_wire_data_out),

			.o_wire_almost_full(fifo_render3_o_wire_almost_full),
			.o_wire_full(fifo_render3_o_wire_full),
			
			.o_wire_almost_empty(fifo_render3_o_wire_almost_empty),
			.o_wire_empty(fifo_render3_o_wire_empty),
			.o_wire_data_count(),
			.o_wire_empty_count()
		);
		assign fifo_render3_i_wire_resetn=renderer_o_wire_fifo2_resetn&&renderer_o_wire_fifo1_resetn;
		assign fifo_render3_i_wire_write=blender_o_wire_data_valid;
		assign fifo_render3_i_wire_data_in=blender_o_wire_data_out;

		//////////////////////////////////////////////////////////////////////////////
		//dma writer
		//////////////////////////////////////////////////////////////////////////////

		wire dma_writer_i_wire_resetn0;
		wire dma_writer_i_wire_resetn1;
		wire dma_writer_i_wire_resetn2;

		wire dma_writer_i_wire_router0;
		wire dma_writer_i_wire_router1;
		wire dma_writer_i_wire_router2;

		wire dma_writer_o_wire_done;

		wire[31:0] dma_writer_i_wire_address0;
		wire[31:0] dma_writer_i_wire_address1;
		wire[31:0] dma_writer_i_wire_address2;

		wire[31:0] dma_writer_i_wire_length0;
		wire[31:0] dma_writer_i_wire_length1;
		wire[31:0] dma_writer_i_wire_length2;

		wire[31:0] dma_writer_i_wire_data0;
		wire[31:0] dma_writer_i_wire_data1;
		wire[31:0] dma_writer_i_wire_data2;

		wire dma_writer_i_wire_data_valid0;
		wire dma_writer_i_wire_data_valid1;
		wire dma_writer_i_wire_data_valid2;


		wire[3:0] dma_writer_o_wire_data_next;

		wire dma_writer_o_wire_data_next0;
		wire dma_writer_o_wire_data_next1;
		wire dma_writer_o_wire_data_next2;

		assign dma_writer_o_wire_data_next0=dma_writer_o_wire_data_next[0];
		assign dma_writer_o_wire_data_next1=dma_writer_o_wire_data_next[1];
		assign dma_writer_o_wire_data_next2=dma_writer_o_wire_data_next[2];

		wire dma_writer_o_wire_error;


		painterengine_gpu_dma_writer dma_writer(
			.i_wire_clock(i_wire_clock),
			.i_wire_resetn(i_wire_resetn&&(dma_writer_i_wire_router0|dma_writer_i_wire_router1|dma_writer_i_wire_router2)),
			.i_wire_router({1'b0,dma_writer_i_wire_router2,dma_writer_i_wire_router1,dma_writer_i_wire_router0}),
			.o_wire_done(dma_writer_o_wire_done),

			.i_wire_address({32'd0,dma_writer_i_wire_address2,dma_writer_i_wire_address1,dma_writer_i_wire_address0}),
			.i_wire_length({32'd0,dma_writer_i_wire_length2,dma_writer_i_wire_length1,dma_writer_i_wire_length0}),

			.i_wire_data({32'd0,dma_writer_i_wire_data2,dma_writer_i_wire_data1,dma_writer_i_wire_data0}),
			.i_wire_data_valid({1'b0,dma_writer_i_wire_data_valid2,dma_writer_i_wire_data_valid1,dma_writer_i_wire_data_valid0}),

			.o_wire_data_next(dma_writer_o_wire_data_next),
			.o_wire_error(dma_writer_o_wire_error),
			//axi full ports
			.o_wire_M_AXI_AWID(m00_axi_awid),
			.o_wire_M_AXI_AWADDR(m00_axi_awaddr),
			.o_wire_M_AXI_AWLEN(m00_axi_awlen),
			.o_wire_M_AXI_AWSIZE(m00_axi_awsize),
			.o_wire_M_AXI_AWBURST(m00_axi_awburst),
			.o_wire_M_AXI_AWLOCK(m00_axi_awlock),
			.o_wire_M_AXI_AWCACHE(m00_axi_awcache),
			.o_wire_M_AXI_AWPROT(m00_axi_awprot),
			.o_wire_M_AXI_AWQOS(m00_axi_awqos),
			.o_wire_M_AXI_AWVALID(m00_axi_awvalid),
			.i_wire_M_AXI_AWREADY(m00_axi_awready),
			.o_wire_M_AXI_WDATA(m00_axi_wdata),
			.o_wire_M_AXI_WSTRB(m00_axi_wstrb),
			.o_wire_M_AXI_WLAST(m00_axi_wlast),
			.o_wire_M_AXI_WVALID(m00_axi_wvalid),
			.i_wire_M_AXI_WREADY(m00_axi_wready),
			.i_wire_M_AXI_BID(1'b0),
			.i_wire_M_AXI_BRESP(m00_axi_bresp),
			.i_wire_M_AXI_BVALID(m00_axi_bvalid),
			.o_wire_M_AXI_BREADY(m00_axi_bready)
		);

		assign dma_writer_i_wire_router0=memcpy_o_wire_dma_writer_resetn;
		assign dma_writer_i_wire_router1=renderer_o_wire_writer_resetn;
		assign dma_writer_i_wire_router2=colorconvert_o_wire_dma_writer_resetn;

		assign memcpy_i_wire_dma_writer_done=dma_writer_o_wire_done;
		assign renderer_i_wire_dma_writer_done=dma_writer_o_wire_done;
		assign colorconvert_i_wire_dma_writer_done=dma_writer_o_wire_done;

		assign dma_writer_i_wire_address0=memcpy_o_wire_dma_writer_address;
		assign dma_writer_i_wire_address1=renderer_o_wire_dma_writer_address;
		assign dma_writer_i_wire_address2=colorconvert_o_wire_dma_writer_address;

		assign dma_writer_i_wire_length0=memcpy_o_wire_dma_writer_length;
		assign dma_writer_i_wire_length1=renderer_o_wire_dma_writer_length;
		assign dma_writer_i_wire_length2=colorconvert_o_wire_dma_writer_length;

		assign dma_writer_i_wire_data0=fifo_memcpy_o_wire_data_out;
		assign dma_writer_i_wire_data1=fifo_render3_o_wire_data_out;
		assign dma_writer_i_wire_data2=fifo_colorconvert_o_wire_data_out;

		assign dma_writer_i_wire_data_valid0=!fifo_memcpy_o_wire_empty;
		assign dma_writer_i_wire_data_valid1=!fifo_render3_o_wire_empty;
		assign dma_writer_i_wire_data_valid2=!fifo_colorconvert_o_wire_empty;

		assign fifo_memcpy_i_wire_read=dma_writer_o_wire_data_next0;
		assign fifo_render3_i_wire_read=dma_writer_o_wire_data_next1;
		assign fifo_colorconvert_i_wire_read=dma_writer_o_wire_data_next2;

		assign memcpy_i_wire_dma_writer_error=dma_writer_o_wire_error;
		assign renderer_i_wire_writer_error=dma_writer_o_wire_error;
		assign colorconvert_i_wire_dma_writer_error=dma_writer_o_wire_error;

	endmodule
