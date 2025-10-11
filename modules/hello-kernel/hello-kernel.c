#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/init.h>


MODULE_LICENSE("GPL");
MODULE_AUTHOR("SpaceBaker");
MODULE_DESCRIPTION("A simple Hello World kernel module.");


static int __init hello_kernel_init(void)
{
	printk(KERN_INFO "Hello kernel!\n");

	return 0;
}

static void __exit hello_kernel_cleanup(void)
{
	printk(KERN_INFO "Goodbye kernel!\n");
}

module_init(hello_kernel_init);
module_exit(hello_kernel_cleanup);
