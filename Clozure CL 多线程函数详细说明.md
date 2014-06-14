# Clozure CL 多线程函数详细说明

`补充：本文尚未完成，存在多处拷贝错误，还需要修改，应某位网友要求先发布一个半成品的草稿，谢谢`

## 目录

*	[一、简单介绍](#1)
*	[二、多线程相关全局变量](#2)
	*	[1、\*current-process\*](#2-1)
	*	[2、\*ticks-per-second\*](#2-2)
*	[三、多线程相关函数](#3)
	*	[1、all-processes](#3-1)
	*	[2、make-proces](#3-2)
	*	[3、process-suspend](#3-3)
	*	[4、process-resume](#3-4)
	*	[5、process-suspend-count](#3-5)
	*	[6、process-preset](#3-6)
	*	[7、process-enable](#3-7)
	*	[8、process-run-function](#3-8)
	*	[9、all-processes](#3-9)
	*	[10、make-proces](#3-10)
	*	[11、all-processes](#3-11)
	*	[12、make-proces](#3-12)
	*	[13、process-suspend](#3-13)
	*	[14、process-resume](#3-14)
	*	[15、process-suspend-count](#3-15)
	*	[16、process-preset](#3-16)
	*	[17、process-enable](#3-17)
	*	[18、process-run-function](#3-18)
	*	[19、all-processes](#3-19)
	*	[20、make-proces](#3-20)
	*	[21、all-processes](#3-21)
	*	[22、make-proces](#3-22)
	*	[23、process-suspend](#3-23)
	*	[24、process-resume](#3-24)
	*	[25、process-suspend-count](#3-25)
	*	[26、process-preset](#3-26)
	*	[27、process-enable](#3-27)
	*	[28、process-run-function](#3-28)
	*	[29、all-processes](#3-29)
*	[四、多线程相关宏](#4)
	*	[1、without-interrupts](#4-1)
	*	[2、with-interrupts-enabled](#4-2)
	*	[3、with-lock-grabbed](#4-3)
	*	[4、with-read-lock](#4-4)
	*	[5、with-write-lock](#4-5)
	*	[6、with-terminal-input](#4-6)
	*	[7、待定](#4-7)



	

## [一、简单介绍](id:1)

本文主要根据 CCL 的官方文档多线程的内容（Threads Dictionary）进行翻译和扩展，为每个线程函数增加一到二个使用范例，便于初学者理解使用，如果感觉翻译有误，请以原文档为准。

## [二、多线程相关全局变量](id:2)

### [1、\*current-process\*](id:2-1)

实现功能：保存当前正处于激活态的线程

输入参数：无

返回结果：当前线程

使用方法：\*current-process\*

范例：

#### 1）直接显示

	? *current-process*
	#<COCOA-LISTENER-PROCESS Listener(15) [Active] #x30200108839D>
	? 

#### 2）绑定到全局变量

	? (defparameter *selected-process* *current-process*)
	*SELECTED-PROCESS*
	? *SELECTED-PROCESS*
	#<COCOA-LISTENER-PROCESS Listener(15) [Active] #x30200108839D>
	? 

### 2、[\*ticks-per-second\*](id:2-2)

实现功能：每秒时间片

输入参数：无

返回结果：每秒时间片

使用方法：\*ticks-per-second\*

范例：

#### 1）直接显示

	? *ticks-per-second*
	100
	? 


## [三、多线程相关函数](id:3)

### [1、all-processes](id:3-1)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(all-processes)
	
【范例】：

#### 1）直接获取线程列表

	? (all-processes)
	(#<COCOA-LISTENER-PROCESS Listener(15) [Active] #x30200108839D> #<PROCESS sleeper(13) 	[Reset] #x3020010572ED> #<PROCESS sleeper(10) [semaphore wait] #x30200102EDED> #<PROCESS 	sleeper(7) [semaphore wait] #x302000E07A9D> #<PROCESS housekeeping(5) [Sleep] 	#x302000DF69FD> #<APPKIT-PROCESS Initial(0) [Reset] #x3020000C0B5D>)
	? 
	
#### 2）选择线程对象

	? (defparameter *selected-process* (second (all-processes)))
	*SELECTED-PROCESS*
	? *SELECTED-PROCESS*
	#<PROCESS sleeper(13) [Reset] #x3020010572ED>
	? 
	
#### 3) 循环打印全部线程对象

	? (loop for i from 0 to (- (length (all-processes)) 1) 
		do (print (nth i (all-processes))))

	#<COCOA-LISTENER-PROCESS Listener(15) [Active] #x302000FF987D> 
	#<PROCESS sleeper(13) [Reset] #x302000FF486D> 
	#<PROCESS sleeper(10) [semaphore wait] #x302000FEAEED> 
	#<PROCESS sleeper(7) [semaphore wait] #x302000E07A9D> 
	#<PROCESS housekeeping(5) [Sleep] #x302000DF69FD> 
	#<APPKIT-PROCESS Initial(0) [Reset] #x3020000C0B5D> 
	NIL
	?

### [2、make-process](id:3-2)

实现功能：创建并返回一个新的线程对象

输入参数：
	
	name 					线程名，字符串类型，如 "process1"
	&key persistent 		布尔类型，默认为 nil
		 priority 			优先级，因为不同平台实现的复杂，该参数通常被忽略，默认为0
		 class 				新建线程对象的类，应该为 CCL:PROCESS 的子类，默认为 CCL:PROCESS
		 initargs 			所有准备传递给 MAKE-INSTANCE 的附加初始化参数列表，默认为（）
		 stack-size 		新建线程的控制栈的大小，默认值为 CCL:*DEFAULT-CONTROL-STACK-SIZE*
		 vstack-size 		新建线程的数值栈的大小，默认值为 CCL:*DEFAULT-VALUE-STACK-SIZE*
		 tstack-size 		新建线程的临时栈的大小，默认值为 CCL:*DEFAULT-TEMP-STACK-SIZE*
		 initial-bindings 	一个 (symbol . valueform) 的 alist 对，默认值为 nil
		 use-standard-initial-bindings 	 布尔类型，默认值为 T

返回结果：新创建的线程对象

附加描述：

	使用指定的属性创建和返回一个线程对象，但是创建的线程对象不会立即执行，它需要首先被 preset （使用 	process-preset），然后被 enable （使用 process-enable），之后才会实际运行起来

使用方法：(make-process “*process1*”)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [3、process-suspend](id:3-3)

实现功能：挂起指定线程

输入参数：一个线程对象，目前只支持以全局变量的形式绑定的线程对象

返回结果：操作结果，T 或 nil

使用方法：(process-suspend *process*)
	
【范例】：

#### 1）挂起一个处于 reset 状态的线程

	? (all-processes)
	(#<COCOA-LISTENER-PROCESS Listener(15) [Active] #x30200108839D> #<PROCESS sleeper(13) 	[Reset] #x3020010572ED> #<PROCESS sleeper(10) [semaphore wait] #x30200102EDED> #<PROCESS 	sleeper(7) [semaphore wait] #x302000E07A9D> #<PROCESS housekeeping(5) [Sleep] 	#x302000DF69FD> #<APPKIT-PROCESS Initial(0) [Reset] #x3020000C0B5D>)
	? 
	？(defparameter *selected-process* (second (all-processes)))
	*SELECTED-PROCESS*
	? *SELECTED-PROCESS*
	#<PROCESS sleeper(13) [Reset] #x3020010572ED>
	? (process-suspend *selected-process*)
	T
	? *SELECTED-PROCESS*
	#<PROCESS sleeper(13) [Reset] #x3020010572ED>
	?
	

#### 2）挂起一个处于 semaphore wait 状态的线程

	? (defparameter *selected-process* (third (all-processes)))
	*SELECTED-PROCESS*
	? *SELECTED-PROCESS*
	#<PROCESS sleeper(10) [semaphore wait] #x30200102EDED>
	? (process-suspend *selected-process*)
	NIL
	? *SELECTED-PROCESS*
	#<PROCESS sleeper(10) [semaphore wait] #x30200102EDED>
	? 

### [4、process-resume](id:3-4)

实现功能：恢复一个线程

输入参数：一个线程对象，目前只支持以全局变量的形式绑定的线程对象

返回结果：操作结果，T 或 nil

使用方法：(process-resume *process*)
	
【范例】：

#### 1）恢复一个线程，返回 T

	? (defparameter *selected-process* (second (all-processes)))
	*SELECTED-PROCESS*
	? *SELECTED-PROCESS*
	#<PROCESS sleeper(13) [Reset] #x3020010572ED>
	? (process-resume *SELECTED-PROCESS*)
	T
	? *SELECTED-PROCESS*
	#<PROCESS sleeper(13) [Reset] #x3020010572ED>
	? 

#### 2）恢复一个线程，返回 nil

	? *SELECTED-PROCESS*
	#<PROCESS sleeper(10) [semaphore wait] #x30200102EDED>
	? (process-resume *SELECTED-PROCESS*)
	NIL
	?

### [5、process-suspend-count](id:3-5)

实现功能：线程挂起次数

输入参数：一个线程对象，目前只支持以全局变量的形式绑定的线程对象

返回结果：操作结果，一个数字 或 nil（线程过期则返回 nil）

使用方法：(process-suspend-count *process*)
	
【范例】：

#### 1）返回线程挂起次数

	? (defparameter *selected-process* (third (all-processes)))
	*SELECTED-PROCESS*
	? *SELECTED-PROCESS*
	#<PROCESS sleeper(10) [semaphore wait] #x30200102EDED>
	? (process-suspend-count *selected-process*)
	1
	? 
	
#### 2）返回线程挂起次数

	? *SELECTED-PROCESS*
	#<PROCESS sleeper(13) [Reset] #x3020010572ED>
	? (process-suspend-count *selected-process*)
	0
	? 

### [6、process-preset](id:3-6)

实现功能：为指定线程设置的初始化函数和参数

输入参数：

	process			一个线程对象，目前只支持以全局变量的形式绑定的线程对象
	function		一个函数
	&rest args		函数的参数

返回结果：未确定，取决于函数的返回结果

使用方法：(process-preset *process* function (arg1 arg2 argn))
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [7、process-enable](id:3-7)

实现功能：开始执行指定线程的初始化函数

输入参数：

	process				一个线程对象，目前只支持以全局变量的形式绑定的线程对象
	&optional timeout	可选参数，超时时长，以秒为单位的时间间隔，最大不超过 32 位字长，默认为 1

返回结果：线程对象的列表

使用方法：(process-enable *process* 超时时间)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [8、process-run-function](id:3-8)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	name			用来标识线程的字符串. 会传递给 make-process.
	function		函数，会传递给 make-process.
	persistent		布尔值，会传递给 make-process.
	priority		优先级，忽略
	class			CCL:PROCESS的一个子类，会传递给 make-process.
	initargs		额外的初始化参数列表，会传递给 make-process. 
	stack-size		控制栈大小，单位 bytes，会传递给 make-process.
	vstack-size		数值栈大小，单位 bytes，会传递给 make-process.
	tstack-size		临时栈大小，单位 bytes，会传递给 make-process.
	
返回结果：线程对象的列表

附加说明：

本函数 通过 make-process 创建一个线程，然后分别通过  process-preset 和 process-enable 对其 preset 和 enable，这样这个线程就可以立即运行，使用 process-run-function 是最简单的创建和执行线程的方法。

使用方法：(process-run-function process-specifier function &rest args)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [9、process-interrupt](id:3-9)

实现功能：中断线程

输入参数：

	process---a lisp process (thread).
	function---a function.
	args---a list of values, appropriate as arguments to function.

返回结果：线程对象的列表

使用方法：(process-interrupt process function &rest args)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [10、process-reset](id:3-10)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	process---a lisp process (thread).
	kill-option---an internal argument, must be nil.

返回结果：线程对象的列表

使用方法：(process-reset process &optional kill-option)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [11、process-reset-and-enable](id:3-11)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(process-reset-and-enable *process*)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [12、process-kill](id:3-12)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(process-kill process)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [13、process-abort](id:3-13)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(process-abort process &optional condition)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [14、process-whostate](id:3-14)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(process-whostate process)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [15、process-allow-schedule](id:3-15)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(process-allow-schedule)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [16、make-process](id:3-16)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	whostate---a string, which will be the value of process-whostate while the process is waiting.
	function---a function, designated by itself or by a symbol which names it.
	args---a list of values, appropriate as arguments to function.



返回结果：线程对象的列表

使用方法：(process-wait whostate function &rest args)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [17、process-wait-with-timeout](id:3-17)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	whostate---a string, which will be the value of process-whostate while the process is waiting.
	ticks---either a positive integer expressing a duration in "ticks" (see *ticks-per-second*), or NIL.
	function---a function, designated by itself or by a symbol which names it.
	args---a list of values, appropriate as arguments to function.


返回结果：线程对象的列表

使用方法：(process-wait-with-timeout whostate ticks function args)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [18、make-lock](id:3-18)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	name---any lisp object; saved as part of lock. Typically a string or symbol which may appear in the process-whostates of threads which are waiting for lock.

返回结果：线程对象的列表

使用方法：(make-lock &optional name)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [19、grab-lock](id:3-19)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(grab-lock lock)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [20、release-lock](id:3-20)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(release-lock lock)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [21、try-lock](id:3-21)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(try-lock lock)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [22、make-read-write-lock](id:3-22)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(make-read-write-lock)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [23、make-semaphore](id:3-23)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(make-semaphore)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [24、signal-semaphore](id:3-24)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(signal-semaphore semaphore)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [25、wait-on-semaphore](id:3-25)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(wait-on-semaphore semaphore)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [26、timed-wait-on-semaphore](id:3-26)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(timed-wait-on-semaphore semaphore timeout)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [27、process-input-wait](id:3-27)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：无

返回结果：线程对象的列表

使用方法：(process-input-wait fd &optional timeout)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [28、process-output-wait](id:3-28)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	fd---a file descriptor, which is a non-negative integer used by the OS to refer to an open file, socket, or similar I/O connection. See ccl::stream-device.
	timeout---either NIL or a time interval in milliseconds. Must be a non-negative integer. The default is NIL.


返回结果：线程对象的列表

使用方法：(process-output-wait fd &optional timeout)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程

### [29、join-process](id:3-29)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	process---a process, typically created by process-run-function or by make-process

	default---A default value to be returned if the specified process doesn't exit normally.



返回结果：线程对象的列表

使用方法：(join-process process &optional default)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


## [四、多线程相关宏](id:4)

### [1、without-interrupts](id:4-1)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	body---an implicit progn.

返回结果：线程对象的列表

使用方法：(without-interrupts &body body)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [2、with-interrupts-enabled](id:4-2)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	body---an implicit progn.

返回结果：线程对象的列表

使用方法：(with-interrupts-enabled &body body)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [3、with-lock-grabbed](id:4-3)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	lock---an object of type CCL:LOCK.
	body---an implicit progn.

返回结果：线程对象的列表

使用方法：(with-lock-grabbed (lock) &body body)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [4、with-read-lock](id:4-4)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	read-write-lock---an object of type CCL:READ-WRITE-LOCK.
	body---an implicit progn.

返回结果：线程对象的列表

使用方法：(with-read-lock (read-write-lock) &body body)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [5、with-write-lock](id:4-5)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	process---a process, typically created by process-run-function or by make-process

	default---A default value to be returned if the specified process doesn't exit normally.



返回结果：线程对象的列表

使用方法：with-write-lock (read-write-lock) &body body)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [6、with-terminal-input](id:4-6)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	body---an implicit progn.

返回结果：线程对象的列表

使用方法：(with-terminal-input &body body)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程


### [7、待定](id:4-7)

实现功能：获取当前系统中所有已知 Lisp 线程的最新列表

输入参数：

	process---a process, typically created by process-run-function or by make-process

	default---A default value to be returned if the specified process doesn't exit normally.

返回结果：线程对象的列表

使用方法：(join-process process &optional default)
	
【范例】：

#### 1）使用默认值创建一个线程

#### 2）指定参数值创建一个线程











































