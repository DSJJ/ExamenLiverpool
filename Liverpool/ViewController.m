//
//  ViewController.m
//  Liverpool
//
//  Created by David Sinai Jiménez Jiménez on 24/02/18.
//  Copyright © 2018 David Sinai Jiménez Jiménez. All rights reserved.
//

#import "ViewController.h"

#import "TableViewCell.h"

#import "AFNetworking.h"
#import "UIImageView+WebCache.h"

@interface ViewController ()
{
    NSMutableArray *filteredContentList;
    BOOL isSearching;
    NSMutableArray *datos;
}
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    filteredContentList = [[NSMutableArray alloc]initWithArray:[self getArray]];
    

    [self buscarProducto:@"computadora"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setArray:(NSMutableArray*)array
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    [userdefaults setValue:array forKey:@"Busquedas"];
    [userdefaults synchronize];
}

-(NSMutableArray*)getArray
{
    NSUserDefaults *userdefaults = [NSUserDefaults standardUserDefaults];
    NSMutableArray *result=[[NSMutableArray alloc] initWithArray:[userdefaults valueForKey:@"Busquedas"]];
    return result;
}

-(void)buscarProducto:(NSString *)producto
{
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [securityPolicy setValidatesDomainName:NO];
    [securityPolicy setAllowInvalidCertificates:YES];
    manager.securityPolicy = securityPolicy;
    
    NSString *URLString = [NSString stringWithFormat:@"https://www.liverpool.com.mx/tienda?s=%@&d3106047a194921c01969dfdec083925=json",producto];
    
    NSURLRequest *request = [[AFJSONRequestSerializer serializer] requestWithMethod:@"GET" URLString:URLString parameters:nil error:nil];
    
    NSURLSessionDataTask *dataTask = [manager dataTaskWithRequest:request
                                                   uploadProgress:nil
                                                 downloadProgress:nil
                                                completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
                                                    
                                                    if (error)
                                                    {
                                                        NSLog(@"Error: %@", error);
                                                        
                                                        UIAlertController * alert = [UIAlertController
                                                                                     alertControllerWithTitle:@"Atención"
                                                                                     message:@"Ha ocurrido un problema inesperado, intenta mas tarde y valida tu conexión"
                                                                                     preferredStyle:UIAlertControllerStyleAlert];
                                                        
                                                        UIAlertAction* noButton = [UIAlertAction
                                                                                   actionWithTitle:@"Continuar"
                                                                                   style:UIAlertActionStyleDefault
                                                                                   handler:nil];
                                                        
                                                        [alert addAction:noButton];
                                                        
                                                        [self presentViewController:alert animated:YES completion:nil];
                                                    }else
                                                    {
                                                        //NSLog(@"Respuesta API\n%@", responseObject);
                                                        
                                                        datos = [[NSMutableArray alloc] init];
                                                        
                                                         NSArray *listas = [[[responseObject objectForKey:@"contents"]objectAtIndex:0]objectForKey:@"mainContent"];
                                                        
                                                        datos = [[[[listas objectAtIndex:listas.count-1] objectForKey:@"contents"] objectAtIndex:0] objectForKey:@"records"];
                                                        
                                                        [self.tableView reloadData];
                                                    }
                                                }];
    [dataTask resume];
}


#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearching)
        return 32;
    else
        return 96;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    int Contador = 0;
    
    if (isSearching)
        Contador = (int)filteredContentList.count;
    else
        Contador = (int)datos.count;
    
    return Contador;
}

 - (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
 
     static NSString *CellIdentifier = @"CustomCell";
     
     if (isSearching) {
    
         UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
         cell.textLabel.text = [filteredContentList objectAtIndex:indexPath.row];
         return cell;
     }else{
         //Ejemplificando el uso de XIB que se menciona en el examen, bien esto puede realizarse desde el storyboard
         TableViewCell *cell = nil;
         
         cell =(TableViewCell *) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
         NSArray *nib= [[NSBundle mainBundle] loadNibNamed:@"TableViewCell" owner:self options:nil];
         cell = (TableViewCell *)[nib objectAtIndex:0];

         cell.lb_titulo.text = [[[[datos objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"product.displayName"] objectAtIndex:0];
         
         NSNumberFormatter *formatter = [NSNumberFormatter new];
         [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
         
         NSNumber *someNumber = [NSNumber numberWithDouble:[[[[[datos objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"sku.list_Price"] objectAtIndex:0] floatValue]];
         
         cell.lb_precio.text = [formatter stringFromNumber:someNumber];
         
         //No encontre el valor de ubicación agrego calificación en su lugar
         cell.lb_calificacion.text = [NSString stringWithFormat:@"Calificación: %@",[[[[datos objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"productAvgRating"] objectAtIndex:0]];
         
         //Use este valor product.smallImage para la imagenes ya que es mas pequeña y asi mejorar la descarga de las imagenes
         NSString * img_str = [[[[datos objectAtIndex:indexPath.row] objectForKey:@"attributes"] objectForKey:@"product.smallImage"] objectAtIndex:0];
         
         [cell.img_thubnail sd_setImageWithURL:[NSURL URLWithString:img_str]
                              placeholderImage:[UIImage imageNamed:@"Avatar_Doc"]
                                       options:SDWebImageRetryFailed];
         
         return cell;
     }
 }

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (isSearching)
    {
        isSearching = NO;
        [self buscarProducto:[filteredContentList objectAtIndex:indexPath.row]];
        [self.view endEditing:YES];
    }
}

#pragma mark - Search
- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {

    isSearching = YES;
    [self.tableView reloadData];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    [self.view endEditing:YES];
    isSearching = NO;
    searchBar.text = @"";
    [self.tableView reloadData];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    isSearching = NO;
    
    //TODO se puede optimizar para que no agregue elementos repetidos
    [filteredContentList addObject:_searchBar.text];
    [self setArray:filteredContentList];

    [self buscarProducto:_searchBar.text];
    [self.view endEditing:YES];
}


@end
