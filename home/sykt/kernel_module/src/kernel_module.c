#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/ioport.h>
#include <asm/errno.h>
#include <asm/io.h>

MODULE_INFO(intree, "Y");
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Jakub Pasierb");
MODULE_VERSION("0.01");

#define SYKT_GPIO_BASE_ADDR (0x00100000)
#define SYKT_GPIO_SIZE (0x8000)
#define SYKT_EXIT (0x3333)
#define SYKT_EXIT_CODE (0x7F)

#define SYKT_CTRL_ADDR		(0x00100000)
#define SYKT_EXIT_VAL		(0x00004444)

#define SYKT_GPIO_ADDR_SPACE (baseptr)
#define SYKT_GPIO_A1_ADDR	(SYKT_GPIO_ADDR_SPACE+0x000000D8)
#define SYKT_GPIO_A2_ADDR	(SYKT_GPIO_ADDR_SPACE+0x000000DC)
#define SYKT_GPIO_W_ADDR	(SYKT_GPIO_ADDR_SPACE+0x000000E0)
#define SYKT_GPIO_S_ADDR	(SYKT_GPIO_ADDR_SPACE+0x000000E4)

void __iomem *baseptr;

static struct kobject *sykt_sysfs; // creating a pointer to an object
static unsigned int pjebarg1;
static unsigned int pjebarg2;
static unsigned int pjebresult;
static unsigned int pjebstatus;

// Reading arguments A1 and A2 and writing them to the appropriate memory location
static ssize_t pjebarg1_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buffer, size_t count){
	sscanf(buffer, "%x", &pjebarg1);
	writel(pjebarg1, SYKT_GPIO_A1_ADDR);
	return count;
}
static ssize_t pjebarg2_store(struct kobject *kobj, struct kobj_attribute *attr, const char *buffer, size_t count){
	sscanf(buffer, "%x", &pjebarg2);
	writel(pjebarg2, SYKT_GPIO_A2_ADDR);
	return count;
}

// Reading the result of calculations W
static ssize_t pjebresult_show(struct kobject *kobj, struct kobj_attribute *attr, char *buffer){
	pjebresult = readl(SYKT_GPIO_W_ADDR);
    return sprintf(buffer, "%x", pjebresult);
}

// Reading the status of the S operation
static ssize_t pjebstatus_show(struct kobject *kobj, struct kobj_attribute *attr, char *buffer){
	pjebstatus = readl(SYKT_GPIO_S_ADDR);
    return sprintf(buffer, "%x", pjebstatus);
}

// macros
static struct kobj_attribute pjebarg1_attr = __ATTR_WO(pjebarg1);
static struct kobj_attribute pjebarg2_attr = __ATTR_WO(pjebarg2);
static struct kobj_attribute pjebresult_attr = __ATTR_RO(pjebresult);
static struct kobj_attribute pjebstatus_attr = __ATTR_RO(pjebstatus);


int my_init_module(void){
	int error = 0;
	
	printk(KERN_INFO "Init my sykom module.\n");
	baseptr=ioremap(SYKT_GPIO_BASE_ADDR, SYKT_GPIO_SIZE);
	
	sykt_sysfs = kobject_create_and_add("sykom", kernel_kobj);
	if(!sykt_sysfs) return -ENOMEM;

    error = sysfs_create_file(sykt_sysfs, &pjebarg1_attr.attr);
    if (error) {
        printk(KERN_INFO "Failed to create the pjebarg1 file in /sys/sykom/pjebarg1 \n");
    }
	
	error = sysfs_create_file(sykt_sysfs, &pjebarg2_attr.attr);
    if (error) {
        printk(KERN_INFO "Failed to create the pjebarg2 file in /sys/sykom/pjebarg2 \n");
		sysfs_remove_file(kernel_kobj, &pjebarg1_attr.attr);
    }
	
	error = sysfs_create_file(sykt_sysfs, &pjebresult_attr.attr);
    if (error) {
        printk(KERN_INFO "Failed to create the pjebresult file in /sys/sykom/pjebresult \n");
		sysfs_remove_file(kernel_kobj, &pjebarg1_attr.attr);
		sysfs_remove_file(kernel_kobj, &pjebarg2_attr.attr);
    }
	
	error = sysfs_create_file(sykt_sysfs, &pjebstatus_attr.attr);
    if (error) {
        printk(KERN_INFO "Failed to create the pjebstatus file in /sys/sykom/pjebstatus \n");
		sysfs_remove_file(kernel_kobj, &pjebarg1_attr.attr);
		sysfs_remove_file(kernel_kobj, &pjebarg2_attr.attr);
		sysfs_remove_file(kernel_kobj, &pjebresult_attr.attr);
    }

	return error;
}

void my_cleanup_module(void){
	printk(KERN_INFO "Cleanup my sykom module.\n");
	writel(SYKT_EXIT | ((SYKT_EXIT_CODE)<<16), baseptr);
	
	kobject_put(sykt_sysfs);
	sysfs_remove_file(kernel_kobj, &pjebarg1_attr.attr);
	sysfs_remove_file(kernel_kobj, &pjebarg2_attr.attr);
	sysfs_remove_file(kernel_kobj, &pjebresult_attr.attr);
	sysfs_remove_file(kernel_kobj, &pjebstatus_attr.attr);
	
	iounmap(baseptr);
}

module_init(my_init_module)
module_exit(my_cleanup_module) 
