# Tracing-Curvature
This code traces the bounday of an object from an image and detect the points having curvature.
The basic idea behind this code is from Freeman's Chain coding algorithm. (https://ieeexplore.ieee.org/document/5219197?arnumber=5219197&tag=1),(http://www.sciencedirect.com/science/article/pii/S0031320304003723)
It used eight-direction code word system to trace the directional changes between pixels along the edge. 
In this code, a modified version of original chain coding is applied. 
Unlike the conventional one, we used two code sysetem to trace both horizonal and vertical curvature changes. 

# Code-word systems
            Horizontal direction-to-code convention is:  1  0  -1
                                                          \ | /
                                                       1 -- P -- -1
                                                          / | \
                                                         1  0  -1

             Vertical direction-to-code convention is:  1  1  1
                                                         \ | /
                                                      0 -- P -- 0
                                                         / | \
                                                       -1 -1  -1
 
 P is the current pixel which we are tracing and its adjacent pixel locates (upper right corner), a code word value (-1 in horizontal detection) and  ( 1 in vertical detection) can be assigned. 
 After assigning the code word values for all pixels along the edge a differential operation is conducted to detect the points showing curvature. The points having code word values which are not equal to zero after differential operation can be assigned as the points showing curvature.
