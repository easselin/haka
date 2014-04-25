/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/. */

/**
 * \file
 * Time representation.
 */

#ifndef _HAKA_TIME_H
#define _HAKA_TIME_H

#include <haka/types.h>

#include <time.h>


/**
 * Time structure.
 */
struct time {
	time_t       secs;   /**< Seconds */
	uint32       nsecs;  /**< Nano-seconds */
};

#define TIME_BUFSIZE    27         /**< String buffer minimum size. */
#define INVALID_TIME    { 0, 0 }   /**< Static initializer for the struct time. */

/**
 * Build a new time structure from a number of seconds.
 */
void       time_build(struct time *t, double secs);

/**
 * Get a current timestamp.
 */
bool       time_gettimestamp(struct time *t);

/**
 * Add two time object.
 */
void       time_add(struct time *t1, const struct time *t2);

/**
 * Compute the difference between two time object.
 */
double     time_diff(const struct time *t1, const struct time *t2);

/**
 * Compare two time object.
 */
int        time_cmp(const struct time *t1, const struct time *t2);

/**
 * Convert time to a number of seconds.
 */
double     time_sec(const struct time *t);

/**
 * Convert time to a string
 * \see TIME_BUFSIZE
 */
bool       time_tostring(const struct time *t, char *buffer, size_t len);

/**
 * Check if the time is valid.
 */
bool       time_isvalid(const struct time *t);

#endif /* _HAKA_TIME_H */
