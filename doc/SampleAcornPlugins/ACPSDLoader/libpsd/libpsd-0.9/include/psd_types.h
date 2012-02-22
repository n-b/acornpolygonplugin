#ifndef __PSD_TYPES_H__
#define __PSD_TYPES_H__

#include <stddef.h>


typedef unsigned char			psd_bool;
#define psd_true				1
#define psd_false				0


typedef char					psd_char;
typedef unsigned char			psd_uchar;
typedef short					psd_short;
typedef unsigned short			psd_ushort;
//typedef int					psd_int;
//typedef unsigned int			psd_uint;
typedef float					psd_float;
typedef double					psd_double;


typedef unsigned char			psd_color_component;
typedef unsigned int			psd_argb_color;



#if __LP64__ || TARGET_OS_EMBEDDED || TARGET_OS_IPHONE || TARGET_OS_WIN32 || NS_BUILD_32_LIKE_64
typedef long					psd_int;
typedef unsigned long			psd_uint;
#else
typedef int						psd_int;
typedef unsigned int			psd_uint;
#endif







#endif
