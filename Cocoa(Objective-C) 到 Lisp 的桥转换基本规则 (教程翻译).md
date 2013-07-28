# Cocoa(Objective-C) 到 Lisp 的桥转换基本规则 (教程翻译)

===
原文地址:			
网络: http://trac.clozure.com/ccl/wiki/CocoaBridgeTranslation
原文标题:			
Cocoa Bridge Translation	
翻译者: 		
FreeBlues 2013-07-18

===

## 目录

*	[0 概述 Overview](#0)
*	[1 直接量 literals](#1)
*	[2 类型 types](#2)
*	[3 常量,枚举和变量 constants, enumerations and variables](#3)
*	[4 选择器 selectors](#4)
*	[5 类定义 class definition](#5)
*	[6 方法定义 method definition](#6)
*	[7 实例化对象 instantiating objects](#7)
*	[8 方法调用 method call](#8)
*	[9 调用设置器/设置属性 calling setters/setting properties](#9)


## [0 概述](id:0)

这里有一堆从 OBJ-C 代码到等效的 Clozure CL 的 Cocoa 桥代码之间的转换，示范不同的语言习惯如何编码。这些东西有些是 Clozure CL FFI 的一部分，未指定具体的桥，但它们被包含在这里给出一个总体概览。

## [1 直接量 literals](id:1)

T 和 NIL 被映射到对应的布尔值 YES 和 NO. 所有数字也是可移植的. NSStrings 需要被明确地创建:

Objective-C 的代码为:

	@"some string"
	
对应的 Lisp 代码变为:

	#@"some string"
	
如果你需要在 Lisp 字符串和 NSStrings 之间做转换, 下面的函数就是你想要的.

	(let ((a-lisp-string "foo"))
	  (ccl::%make-nsstring a-lisp-string))
	  
并且当你接收到 NSStrings 时,你同样需要转换:

	(ccl::lisp-string-from-nsstring (#/title some-object))
	
Clozure CL 习惯于自动转换字符串, 不过这很容易引起内存管理问题. 所以一定要确保你所需要的任何 NSStrings 的保持/释放.

	nil
	NULL
	
这两个都是空指针. 在 Lisp 中要使用:

	ccl:+null-ptr+

来表示它们.

## [2 类型 types](id:2)

在其他一些情况下，您可能需要使用类型（不是类）名称, 作为您定义的方法的返回值。

Objective-C 的代码为:
	
	NSInteger
	BOOL

对应的 Lisp 代码变为:

	#>NSInteger
	#>BOOL

## [3 常量枚举和变量 constants, enumerations and variables](id:3)

Objective-C 的代码为:

	NSTitledWindowMask
	NSUTF8StringEncoding
	
对应的 Lisp 代码变为:

	#$NSTitledWindowMask
	#$NSUTF8StringEncoding
	

## [4 选择器 selectors](id:4)

Objective-C 的代码为:

	@selector(someSelector:withParams:)

对应的 Lisp 代码变为:

	(@selector "someSelector:withParams:")

译者注:就是要去掉 Objective-C 代码里的括号--为了避免和 Lisp 的括号发生混淆

## [5 类定义 class definition](id:5)

Objective-C 的代码为:
	
	@interface SomeClass : SuperClass {
	    IBOutlet NSString *aString;
	}

译者注: 这段的代码实际上是 Object-C 中对一个类的接口的定义, 保存在 .h 文件中,也就是头文件, 使用语法形式为:

	 @interface 类名:父类名 
	 {
	   实例变量声明;
	 }
	 - 实例方法声明;
	 + 类方法声明;
	 @end 

对应的 Lisp 代码变为:

	(defclass some-class (super-class)
	  ((a-string :foreign-type :id))
	  (:metaclass ns:+ns-object))
	  
## [6 方法定义 method definition](id:6)

Objective-C 的代码为:

	@implementation SomeClass // just included so we show the class name

	- (id) initWithFrame:(NSRect)frame andStuff:(id)stuff {
	    if ((self = [super initWithFrame:frame])) {
	        // body
	    }
	    return self;
	}

	- (void) viewDidAppear:(BOOL)animated {
	    [super viewDidAppear:animated];
	    // body
	}

译者注: 这段的代码实际上是 Object-C 中对一个类的实现的定义, 具体内容为类的方法的实现代码, 保存在 .m 文件中,也就是存放代码的文件中, 类似于 C 的 .c 文件, 使用的语法形式为:

	@implementation 类名
	- 实例方法实现
	+ 类方法实现
	@end

对应的 Lisp 代码变为:

	(objc:defmethod (#/initWithFrame:andStuff: :id)
	                ((self some-class) (frame #>NSRect) (stuff :id))
	  (let ((new-self (#/initWithFrame: self frame)))
	    (when new-self
	      ;; body
	      )
	    new-self))

	(objc:defmethod (#/viewDidAppear: :void) ((self some-class) (animated #>BOOL))
	  (call-next-method))
	  ;; body
	  )

通常有 CALL-NEXT-METHOD （仅如预期在 OBJ-C 方法中工作），但是，这并不包括你在 OBJ-C 中需要的所有使用场景。如同在 init 方法中常见的，有时你需要使用跟当前方法不同的名字来调用一个 super-method。这就是 CALL-NEXT-METHOD 失败的地方。在上面的例子中, 自己来处理这个问题的最简单的方法是, 把调用 super 当做 调用 self 。

译者注:因为 Common Lisp 的面向对象系统 CLOS 的实现机制跟 Objective-C 有很大的不同, Lisp 的面向对象是基于广义函数的, 而 Objective-C 的面向对象是基于消息的, 所以这里的 Lisp 代码尽量按照 Objective-C 的风格来写了.

## [7 实例化对象 instantiating objects](id:7)

Objective-C 的代码为:

	[[NSWindow alloc] initWithContentRect:NSRectMake(0, 0, 300, 300)
	                            styleMask:NSTitledWindowMask
	                              backing:NSBackingStoreBuffered
	                                defer:YES];

对应的 Lisp 代码变为:

	(make-instance 'ns:ns-window
	  :with-content-rect (ns:make-ns-rect 0 0 300 300)
	  :style-mask #$NSTitledWindowMask
	  :backing #$NSBackingStoreBuffered
	  :defer t)

## [8 方法调用 method call](id:8)

Objective-C 的代码为:

	[self doSomethingToObject:anObject];
	[NSDate date];
	
对应的 Lisp 代码变为:

	(#/doSomethingToObject: self an-object)
	(#/date ns:ns-date)

译者注: Objective-C 的方法调用语法为:

	[接收者 消息]

其中接收者是对象, 消息就是该对象要调用的方法, 所以写成 Common Lisp 的形式就需要把前后顺序调一下: 把方法函数放在前面, 调用方法函数的对象则作为方法函数的参数传递给方法函数.

## [9 调用设置器/设置属性 calling setters/setting properties](id:9)

你可以使用和调用任何其他方法相同的方式来调用 setter ，但要想使它们的工作更像是属性或槽，您也可以对它们使用 SETF。

Objective-C 的代码为:

	[self setName:aName];
	self.name = aName; // provided there is a @property defined

对应的 Lisp 代码变为:

	(#/setName: self aName)
	
或者是
	
	(setf (#/name self) a-name)
	
而 SETF 形式无论是否有一个定义好的属性都将工作，但必须存在一个 getter (例如 (＃/name self))。这是因为 SETF 的用户期望把保存值返回，但 Cocoa 的 setters 一般​​没有返回值。

