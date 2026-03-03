
'''
General Bresenham's Line Drawing Algorithm

The algorithm is taken from:
  https://www.uobabylon.edu.iq/eprints/publication_2_22893_6215.pdf
  
'''

def Bresenham(x1,y1,x2,y2):
    # 1st point
    x = x1
    y = y1
    print(x,y)

    # Get gradient
    dx = x2 - x1
    dy = y2 - y1
    
    # Adjust for negative 'runs & rises'
    sx = sy = 1
    if dx < 0:
        dx = -dx
        sx = -1
    if dy < 0:
        dy = -dy
        sy = -1
    
    # Adjust for |gradient| > 1
    grad_gt_1 = False
    if dy > dx:
        dx,dy = dy,dx
        grad_gt_1 = True
        
    # Set up the initial 'difference' & 'loop adjustments' 
    p = 2*dy - dx
    lt_adj = 2*dy
    gt_adj = 2*dy - 2*dx
    
    # Perform the algorithm
    for _ in range(0, dx):
        if p < 0:
            if grad_gt_1:
                y += sy
            else:
                x += sx
            p += lt_adj
        else:
            x += sx
            y += sy
            p += gt_adj
            
        # Next point
        print(x,y)


# Main Program

Bresenham(0,0,7,2)
