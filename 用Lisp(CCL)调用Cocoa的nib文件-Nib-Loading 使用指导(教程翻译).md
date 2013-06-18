# 用Lisp(CCL)调用Cocoa的nib文件-Nib-Loading 使用指导(教程翻译)

===
原文地址:  	
本地: ~/ccl-1.8-darwinx86/examples/cocoa/nib-loading/HOWTO.html		
网络: http://trac.clozure.com/ccl/browser/trunk/source/examples/cocoa/nib-loading/HOWTO.html		
原文标题:	
Nib-Loading HOWTO		
翻译者: 		
FreeBlues 2013-06-17

===

## 目录

*	[0 概述](#0)
*	[1 Nibfiles 的相关知识](#1)
*	[2 对 Nibfiles 的使用](#2)
*	[3 如何调用一个 nibfile](#3)
	*	[3.1 获取区域 zone](#3.1)
	*	[3.2 建立字典](#3.2)
	*	[3.3 调用 nibfile](#3.3)
*	[4 建立一个 nib-loading 函数](#4)
*	[5 如何卸载 nibfile](#5)


## [0 概述](id:0)

这篇教程说明如何通过对 Lisp 形式(forms)求值, 加载 nibfiles 到正在运行的 Clozure CL 副本中。你可能想通过这种方式加载 nibfiles 来为你正在工作的一个应用程序项目来测试用户界面元素，或使应用程序能够动态加载可选的用户界面元素。

## [1 Nibfiles 的相关知识](id:1)

Cocoa应用程序开发有很大一部分是使用Cocoa框架来创建用户界面元素的。虽然它是完全有可能只是通过对框架的方法调用创建任何用户界面元素，设计用户界面更标准的方式是使用苹果的 InterfaceBuilder 应用程序去创建 nibfiles 文件, 这些文件归档于 Objective-C 对象，实现用户界面元素。

Interface builder 是苹果的开发工具附带的一个应用程序。开发工具是 Mac OS X 自带的一个可选的安装，在你使用这个HOWTO之前，您需要确保您的系统上安装了苹果的开发工具。苹果的开发者计划的成员可以免费从苹果的开发者网站下载工具，但通常没有必要。你可以简单地使用 Mac OS X系统磁盘上可选的开发者工具安装程序来安装工具。

## [2 对 Nibfiles 的使用](id:2)

使用 InterfaceBuilder，您可以快速，轻松地创建窗口，对话框，文本字段，按钮和其他用户界面元素。你用 InterfaceBuilder 创建的的界面元素拥有符合苹果人机界面指南规定的标准的外观和行为。

InterfaceBuilder 把对这些对象的描述保存在 nibfiles 文件中。这些文件包含归档的 Objective-C 类和对象表示。当你启动一个应用程序，并加载一个nibfile，Cocoa 运行时(runtime)在内存中创建这些Objective-C 对象，完成任何实例变量引用其他对象, 这些可能已被保存在 nibfile 文件中。总之，nibfile是一个已归档的用户界面对象集合，Cocoa 能够快速，轻松地在内存中把它复苏。

Objective-C 程序员使用 nibfiles 一般的方式是将它们存储在应用程序束(bundle)中。应用程序的Info.plist 文件（也存储在 bundle）的指定哪个 nibfile 是应用程序的主要 nibfile，应用程序启动时自动加载该文件。应用程序也可以从 bundle 进行方法调用动态加载其他 nibfiles。

通过 Clozure CL 编写的 Lisp 应用程序也可以以同样时尚的方式来使用 nibfiles（见 “currency-converter” HOWTO “Cocoa” 的例子文件夹中），但Lisp程序员习惯于高度互动的开发，并可能想在一个运行着的Clozure CL 会话中简单地加载任意一个 nibfile 文件。幸运的是，这非常容易。

## [3 如何调用一个 nibfile](id:3)

让我们开始从 Clozure CL 的 Listener 窗口加载一个非常简单的nibfile。通过启动 Clozure CL 应用程序来开始。

在这份 HOWTO 文件相同的目录，你会发现一个 nibfile 名为 “hello.nib”。这是一个极其简单的nibfile, 它创建了一个带着一条单一问候语的 Cocoa 窗口。我们将使用输入到 Listener 窗口的 Lisp 形式来加载它。

我们要调用的 Objective-C 类方法 loadNibFile:externalNameTable:withZone: 来加载 nibfile 到内存中，按照文件中的描述来创建窗口。不过，首先，我们需要建立一些数据结构，我们将把这些数据结构传递给这个方法。

loadNibFile:externalNameTable:withZone: 的参数就是一个路径名，一个字典对象，以及一个内存区域。随着每个 Objective-C 的方法调用，我们还把收到的消息传递给对象，在这种情况下是类 NSBundle的对象。
	
	译者注:
	这里需要了解 Objective-C 的类方法命名规则, 我暂时还没学会, 等彻底掌握了再详细解释
	
路径名仅仅是一个我们要加载的 nibfile 的引用。这个字典持有对象的引用。在这个简单的例子里，我们将使用它以识别 nibfile 的所有者，在这种情况下，所有者就是应用程序本身。该区域是对即将分配给 nibfile 对象的内存区域的引用。

不要担心，如果你对以上所述都无感的话, 用来创建这些对象的代码是简单明了的，并应有助于澄清这是怎么回事。

### [3.1 获取区域 Zone](id:3.1)

首先，我们将得到​​一个存储区。我们会告诉 Cocoa 在应用程序使用的同一区域中分配 nibfile 对象，因此通过询问应用程序正在使用的那个区域来获取一个区域是一件简单的事情。

我们可以要求任何应用之前，我们需要一个指向它的引用。当 Clozure CL 应用程序启动时，它把一个指向 Cocoa 应用程序对象的引用存储到一个特殊变量\*NSApp\*中。

从改变为 CCL 包开始; 我们将使用的大部分的实用功能都被定义在这个包中：

	? (in-package :ccl)
    #<Package "CCL">
      
我们获得一个运行中的 Clozure CL 应用程序对象的引用在特殊变量\*NSApp*\中。我们可以询问它的区域，也就是它在内存中分配对象的区域：

	? (setf *my-zone* (#/zone *NSApp*))
    #<A Foreign Pointer #x8B000>
      
现在我们有一个应用程序的区域，这是我们需要传递给 loadNibFile:externalNameTable:withZone 的参数之一。

(译者注: 其实就是获得了一个地址变量, 这个地址变量指向这个应用程序在内存中的入口地址)

### [3.2 建立字典](id:3.2)

loadNibFile:externalNameTable:withZone: 的字典参数用于两个目的：识别 nibfile 的属主，并收集顶层(toplevel)对象。

本 nibfile 的属主变成雇主的顶层对象中创建加载的nibfile时，对象如窗口，按钮，等等。一个nibfile的所有者管理的对象加载时创建nibfile的，并为您的代码提供了一种方法来对这些对象的引用。您提供一个所有者对象字典，根据键“NSNibOwner”，。

顶层的对象都是对象，如窗户，被加载时创建的nibfile。为了收集这些，你可以传递一个NSMutableArray对象下的关键NSNibTopLevelObjects。

对于这第一个例子中，我们将通过一个所有者对象（应用程序对象），但我们并不需要收集顶层的对象，所以我们会省略NSNibTopLevelObjects，关键。

	[原文的错误代码:]
	? (setf *my-dict* 
        (#/dictionaryWithObject:forKey: ns:ns-mutable-dictionary
         *my-app* 
         #@"NSNibOwner"))
    #<NS-MUTABLE-DICTIONARY {
    NSNibOwner = <LispApplication: 0x1b8e10>;
    } (#x137F3DD0)>

	译者注: 这段代码文档写错了, 里面的那个 *my-app* 要改为 *NSApp* 才可以得到后面的输出.
	
	[修改后的正确代码:]
	? (setf *my-dict* 
        (#/dictionaryWithObject:forKey: ns:ns-mutable-dictionary
         *NSApp* 
         #@"NSNibOwner"))
    #<NS-MUTABLE-DICTIONARY {
    NSNibOwner = <LispApplication: 0x1b8e10>;
    } (#x137F3DD0)>

	
### [3.3 调用 nibfile](id:3.3)

现在，我们有了我们需要的区域和字典，我们可以加载 nibfile。我们只需要以正确的路径名创建一个NSString 就可以了:

	? (setf *nib-path* 
        (%make-nsstring 
        (namestring "~/LispBox-0.92/ccl-1.8-darwinx86//examples/cocoa/nib-loading/hello.nib")))
	#<NS-MUTABLE-STRING "/Users/admin/LispBox-0.92/ccl-1.8-darwinx86/examples/cocoa/nib-loading/hello.nib" (#x4B4CC60)>
	?
      
现在，我们可以实际加载 nibfile，传递我们已经创建对象的方法：

	? (#/loadNibFile:externalNameTable:withZone: 
        ns:ns-bundle
        *nib-path*
        *my-dict*
        *my-zone*)
	T

译者注: 成功后会弹出一个小窗口, 如下图所示:	
![hello示意](http://static.oschina.net/uploads/space/2013/0617/233314_vbJ1_219279.png)
      
“hello.nib” 文件中定义的窗口应该出现在屏幕上。 loadNibFile:externalNameTable:withZone: 方法返回T来表示它成功地加载了 nibfile，如果它失败了，它将返回NIL。

在这一点上，我们不再需要路径名和字典对象。 \*nib-path\* 我们必须释放：

	? (setf *nib-path* (#/release *nib-path*))
	NIL
      
\*my-dict\* 实例没有被 #/alloc (或者被  MAKE-INSTANCE) 创建，所以这已经是自动释放，我们不需要再次释放。


## [4 建立一个 nib-loading 函数](id:4)

加载一个 nibfile 似乎就像我们可能要反复地做的事情，所以尽可能让它变得容易是有道理的。让我们做一个单一的函数，我们可以根据需要，调用它来加载一个 nib。

nib-loading 函数可以把 nib 文件作为一个参数来加载，然后按照上一节中所列的步骤序列执行。如果我们仅仅按照字面意思去做，写出来的函数代码会是这个样子：

	(defun load-nibfile (nib-path)
  	  (let* ((app-zone (#/zone \*NSApp\*))
         	(nib-name (%make-nsstring (namestring nib-path)))
         	(dict (#/dictionaryWithObject:forKey: 
                     ns-mutable-dictionary app #@"NSNibOwner")))
        (#/loadNibFile:externalNameTable:withZone: ns:ns-bundle
                                               	nib-name
                                               	dict
                                               	app-zone)))
      
使用这个函数的麻烦是，每次我们调用它都会泄漏字符串。返回前我们需要释放 nib-name。所以, 看看下面这个替代的版本如何？

	(defun load-nibfile (nib-path)
  	  (let* ((app-zone (#/zone \*NSApp*))
         	(nib-name (%make-nsstring (namestring nib-path)))
         	(dict (#/dictionaryWithObject:forKey: 
                		ns-mutable-dictionary app #@"NSNibOwner"))
         	(result (#/loadNibFile:externalNameTable:withZone: ns:ns-bundle
                                                            	nib-name
                                                            	dict
                                                            	app-zone)))
       	(#/release nib-name)
    	   result))
    
这个版本解决了泄漏问题，办法是: 把调用 loadNibFile:externalNameTable:withZone: 的结果绑定到 result，然后在返回调用结果之前，释放了 nib-name。

只是有一个问题：如果我们想用字典来收集 nibfile 的顶层对象，这样我们就可以从我们的代码访问到它们？我们需要函数的另一个版本。

为了收集顶层对象，我们将要传递 NSNibTopLevelObjects 给字典，它被存储在键NSMutableArrayObjects。因此，我们首先需要在 let 形式体里创建这样一个数组对象：

	(let* (...
       (objects-array (#/arrayWithCapacity: ns:ns-mutable-array 16))
       ...)
  ...)
  
现在，我们有存储 nibfile 顶层对象的数组，我们需要修改创建字典的代码，使其不仅包含属主对象，也包含我们刚刚创建的数组：

	(let* (...
         (dict (#/dictionaryWithObjectsAndKeys: ns:ns-mutable-dictionary
                    app #@"NSNibOwner"
                    objects-array #&NSNibTopLevelObjects
                    +null-ptr+))
         ...)
    ...)
    
我们现在要把对象收集起来。我们会创建一个局部变量来存储它们，然后遍历数组对象把他们全都弄到。 （通常情况下，当我们要保持一个对象数组，我们必须把它保留下来。顶层 nib 对象是一种特殊情况：它们是由 nib 加载进程创建, 保留计数为1(a retain count of 1)，当我们通过它们时我们负责释放它们）。

	(let* (...
         (toplevel-objects (list))
         ...)
    	  (dotimes (i (#/count objects-array))
         (setf toplevel-objects 
            (cons (#/objectAtIndex: objects-array i)
                  toplevel-objects)))
    ...)
    
收集对象后，就可以释放该数组，然后返回对象的列表。我们可能会想知道调用是否成功，仍然是可能的，所以我们使用变量 values 来返回顶层对象以及调用成功或失败。

nib-loading 代码的最终版本看起来像这样：

	(defun load-nibfile (nib-path)
  	  (let* ((app-zone (#/zone \*NSApp\*))
         	(nib-name (%make-nsstring (namestring nib-path)))
         	(objects-array (#/arrayWithCapacity: ns:ns-mutable-array 16))
         	(dict (#/dictionaryWithObjectsAndKeys: ns:ns-mutable-dictionary
                    		\*NSApp\* #@"NSNibOwner"
                    		objects-array #&NSNibTopLevelObjects
		    				+null-ptr+))
         	(toplevel-objects (list))
         	(result (#/loadNibFile:externalNameTable:withZone: ns:ns-bundle
                                                            	nib-name
                                                            	dict
                                                            	app-zone)))
    	(dotimes (i (#/count objects-array))
      		(setf toplevel-objects 
            		  (cons (#/objectAtIndex: objects-array i)
                  		toplevel-objects)))
    	(#/release nib-name)
    	(values toplevel-objects result)))
      
现在，我们可以拿一些合适的 nibfile 作为参数来调用这个函数，比如这个 HOWTO 文档中简单的的“hello.nib”：

	? (ccl::load-nibfile "~/LispBox-0.92/ccl-1.8-darwinx86//examples/cocoa/nib-loading/hello.nib")
	(#<NS-WINDOW <NSWindow: 0x5b9810> (#x5B9810)> #<LISP-APPLICATION <LispApplication: 0x1f8be0> (#x1F8BE0)>)
	T
	?	
	
“hello!” 窗口出现在屏幕上，并且两个值被返回。第一个值是已加载的顶层对象列表。第二个值，T表示，已成功加载 nibfile。

## [5 如何卸载 nibfile](id:5)

Cocoa 没有提供通用的的 nibfile-unloading API。替代方案是，如果你要卸载一个 nib，可接受的方法是关闭所有跟 nibfile 相关的窗口，并释放所有顶层对象。这是一个原因，你可能要对你传给 loadNibFile:externalNameTable的:withZone: 的字典对象使用 “NSNibTopLevelObjects” 键--来获得一个顶层对象集合在不再需要 nibfile 时释放这些对象。

在基于文档的 Cocoa 应用程序，主 nibfile 的属主通常是应用程序对象，并且在应用程序运行时，主 nibfile 永远不会被卸载。 副 nibfiles 的属主一般是控制器对象，通常是 NSWindowController 子类的实例。当你使用 NSWindowController 对象加载 nibfiles 时，他们负责加载和卸载 nibfile 对象。
(译者注: 原文中拼写错误 Auxliliary , 正确应为 Auxiliary)

当你试验交互地加载 nibfile 时，您可能无法由创建 NSWindowController 对象加载 nibfiles 来开始，所以你可能需要自己手动做更多的对象管理。一方面，手动加载 nibfiles 可能是主要的应用程序的问题的来源。另一方面，如果您在交互式会话中长期试用 nib-loading ，很可能随着对生存着的并且可能被释放的对象的各种引用，你会被许多丢弃的对象塞满内存而退出。在使用 Listener 探索 Cocoa 时请务必记住这一点时。通过重启 Lisp 您可以随时让您的 Lisp 系统恢复到一个干净的状态，但是理所当然地，你将失去在探索中建立的任何状态。它往往是一个好主意，在一个文本文件上工作，而不是直接在 Listener 上工作，让你有一个你所做过试验的记录。这样的话，如果你需要重新开始（或者，如果你不小心会导致应用程序崩溃），你不会失去你已经获得的所有信息。

## 译者补充说明: 

试验环境需要自行编译的 CCL-IDE 版本(Cocoa-IDE), 或者使用从苹果 APP STORE 下载的 Clozure CL 的 dmg 安装版本也可以, 非 IDE 版本暂时还没搞定, 比如 Emacs 使用的那个命令行的 CCL 版本, 文件名为 dx86cl64 , 这是因为默认编译出来的非 IDE 版本的特性里没有对 Cocoa 和 Objectiv-C 的支持, 输入 \*features\* 就可以看到不同版本支持哪些特性,如下:

1 unix 终端窗口命令行用的版本支持特性:

Air:ccl-1.8-darwinx86 admin$ ./dx86cl64
Welcome to Clozure Common Lisp Version 1.8-r15286M  (DarwinX8664)!
? \*features\*		
(:PRIMARY-CLASSES :COMMON-LISP :OPENMCL :CCL :CCL-1.2 :CCL-1.3 :CCL-1.4 :CCL-1.5 :CCL-1.6 :CCL-1.7 :CCL-1.8 :CLOZURE :CLOZURE-COMMON-LISP :ANSI-CL :UNIX :OPENMCL-UNICODE-STRINGS :OPENMCL-NATIVE-THREADS :OPENMCL-PARTIAL-MOP :MCL-COMMON-MOP-SUBSET :OPENMCL-MOP-2 :OPENMCL-PRIVATE-HASH-TABLES :X86-64 :X86_64 :X86-TARGET :X86-HOST :X8664-TARGET :X8664-HOST :DARWIN-HOST :DARWIN-TARGET :DARWINX86-TARGET :DARWINX8664-TARGET :DARWINX8664-HOST :64-BIT-TARGET :64-BIT-HOST :DARWIN :LITTLE-ENDIAN-TARGET :LITTLE-ENDIAN-HOST)		
? 

2 Emacs 用的版本支持的特性:(比前者多了对 slime 的支持)	

CL-USER> \*features\*		
(:SWANK :PRIMARY-CLASSES :COMMON-LISP :OPENMCL :CCL :CCL-1.2 :CCL-1.3 :CCL-1.4 :CCL-1.5 :CCL-1.6 :CCL-1.7 :CCL-1.8 :CLOZURE :CLOZURE-COMMON-LISP :ANSI-CL :UNIX :OPENMCL-UNICODE-STRINGS :OPENMCL-NATIVE-THREADS :OPENMCL-PARTIAL-MOP :MCL-COMMON-MOP-SUBSET :OPENMCL-MOP-2 :OPENMCL-PRIVATE-HASH-TABLES :X86-64 :X86_64 :X86-TARGET :X86-HOST :X8664-TARGET :X8664-HOST :DARWIN-HOST :DARWIN-TARGET :DARWINX86-TARGET :DARWINX8664-TARGET :DARWINX8664-HOST :64-BIT-TARGET :64-BIT-HOST :DARWIN :LITTLE-ENDIAN-TARGET :LITTLE-ENDIAN-HOST)		
CL-USER> 

3 自行编译的 Cocoa-IDE 版本支持的特性:

? \*features\*	
(:EASYGUI :ASDF2 :ASDF :HEMLOCK :APPLE-OBJC-2.0 :APPLE-OBJC :PRIMARY-CLASSES :COMMON-LISP :OPENMCL :CCL :CCL-1.2 :CCL-1.3 :CCL-1.4 :CCL-1.5 :CCL-1.6 :CCL-1.7 :CCL-1.8 :CLOZURE :CLOZURE-COMMON-LISP :ANSI-CL :UNIX :OPENMCL-UNICODE-STRINGS :OPENMCL-NATIVE-THREADS :OPENMCL-PARTIAL-MOP :MCL-COMMON-MOP-SUBSET :OPENMCL-MOP-2 :OPENMCL-PRIVATE-HASH-TABLES :X86-64 :X86_64 :X86-TARGET :X86-HOST :X8664-TARGET :X8664-HOST :DARWIN-HOST :DARWIN-TARGET :DARWINX86-TARGET :DARWINX8664-TARGET :DARWINX8664-HOST :64-BIT-TARGET :64-BIT-HOST :DARWIN :LITTLE-ENDIAN-TARGET :LITTLE-ENDIAN-HOST)		
? 

4 苹果 APP STORE 下载的 dmg 版本支持的特性:

? \*features\*	
(:EASYGUI :ASDF2 :ASDF :HEMLOCK :APPLE-OBJC-2.0 :APPLE-OBJC :PRIMARY-CLASSES :COMMON-LISP :OPENMCL :CCL :CCL-1.2 :CCL-1.3 :CCL-1.4 :CCL-1.5 :CCL-1.6 :CCL-1.7 :CCL-1.8 :CLOZURE :CLOZURE-COMMON-LISP :ANSI-CL :UNIX :OPENMCL-UNICODE-STRINGS :OPENMCL-NATIVE-THREADS :OPENMCL-PARTIAL-MOP :MCL-COMMON-MOP-SUBSET :OPENMCL-MOP-2 :OPENMCL-PRIVATE-HASH-TABLES :X86-64 :X86_64 :X86-TARGET :X86-HOST :X8664-TARGET :X8664-HOST :DARWIN-HOST :DARWIN-TARGET :DARWINX86-TARGET :DARWINX8664-TARGET :DARWINX8664-HOST :64-BIT-TARGET :64-BIT-HOST :DARWIN :LITTLE-ENDIAN-TARGET :LITTLE-ENDIAN-HOST)		
? 

容易看出, 主要的区别是前面, 后面基本一样. 
