/*
 * See https://github.com/howardabrams/fp-for-java for complete code
 * and its documentation.
 */

package org.howardism.intensionals;

import java.util.Iterator;

import javax.management.RuntimeErrorException;

/**
 * A collection of utility functions for dealing with with {@link Set}
 * instances.
 */

public class SetUtils {

    /**
     * Combines two sets into one.
     * @param a  A set
     * @param b  Another set
     * @return   A set containing the elements in both "a" and "b"
     */
    public static <T> Set<T> union(final Set<T> a, final Set<T> b) {
        return new Set<T>() {
            public boolean has(final T n) {
                return a.has(n) || b.has(n);
            }
        };
    }

    /**
     * The intersection between two sets
     * @param a  A set
     * @param b  Another set
     * @return   A set that contains values shared by a and b
     */
    public static <T> Set<T> intersection(final Set<T> a, final Set<T> b) {
        return new Set<T>() {
            public boolean has(final T n) {
                return a.has(n) && b.has(n);
            }
        };
    }

    /**
     * Returns a set where values are in "a" but not in b
     * @param a  A set
     * @param b  Another set
     * @return   A set containing a without b
     */
    public static <T> Set<T> diff(final Set<T> a, final Set<T> b) {
        return new Set<T>() {
            public boolean has(final T n) {
                return a.has(n) && ! b.has(n);
            }
        };
    }

    /**
     * Creates an {@link Iterable} instance over a set.
     * @param s      A set
     * @param lower  the lower bound (which if in the set, will be returned)
     * @param upper  the upper bound (which will not be returned as this is inclusive)
     * @return       An instance that allows you to call <code>iterator</code> to get an {@link Iterator}
     */
    public static <T> Iterable<T> iterate(final Set<T> s, final T lower, final T upper) {
        return new Iterable<T>() {

            public Iterator<T> iterator() {
                return getIterator(s, lower, upper);
            }
        };
    }

    /**
     * Returns an {@link Iterator} instance that works over a set. Only
     * sets that contain integers are supported at this time.
     * Note that the {@link Iterator#remove()} is not supported.
     * @param s      A set
     * @param lower  the lower bound (which if in the set, will be returned)
     * @param upper  the upper bound (which will not be returned as this is inclusive)
     * @return       Allows you to call {@link Iterator#next()}
     */
    public static <T> Iterator<T> getIterator(final Set<T> s, final T lower, final T upper) {
        if (lower == null)
            throw new IllegalArgumentException("Must give a valid lower bound for the interator");
        if (upper == null)
            throw new IllegalArgumentException("Must give a valid upper bound for the interator");

        return new Iterator<T>(){
            T count = lower;

            public boolean hasNext() {
                System.out.println("hasNext(): count="+count + ", upper="+upper + " - " + count.equals(upper));
                return ! count.equals(upper);
            }

            public T next() {
                if ( lower.getClass().isAssignableFrom(java.lang.Integer.class) ) {
                    final T results;
                    if (s.has(count))
                        results = count;
                    else
                        results = (T) incrementInteger((Integer) count + 1);
                    count = (T) incrementInteger((Integer) results + 1);
                    System.out.println("increment(): count="+count + ", upper="+upper + " = " + results);
                    return results;
                }
                else
                    throw new RuntimeErrorException(null, "Only Integers are supported");
            }

            public void remove() {
                throw new RuntimeErrorException(null, "Removing elements from set doesn't make sense");
            }

            public Integer incrementInteger(Integer count) {
                if (count > (Integer) upper)
                    return (Integer) upper;
                else if (s.has((T) count)) {
                    return count;
                }
                else {
                    return incrementInteger(count+1);
                }
            }
        };
    }
}
