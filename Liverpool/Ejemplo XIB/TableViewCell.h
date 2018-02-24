//
//  TableViewCell.h
//  Liverpool
//
//  Created by David Sinai Jiménez Jiménez on 24/02/18.
//  Copyright © 2018 David Sinai Jiménez Jiménez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *img_thubnail;

@property (strong, nonatomic) IBOutlet UILabel *lb_titulo;

//No encontre el valor de ubicación agrego calificación en su lugar 
@property (strong, nonatomic) IBOutlet UILabel *lb_calificacion;

@property (strong, nonatomic) IBOutlet UILabel *lb_precio;

@end
