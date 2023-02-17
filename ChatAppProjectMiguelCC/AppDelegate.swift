//
//  AppDelegate.swift
//  ChatAppProjectMiguelCC
//
//  Created by Escuela de Tecnologías Aplicadas on 3/2/23.
//

import UIKit
import UserNotifications //se tiene que importar para poder recibir las notificaciones

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    
    //creando la conexion entre appdelegate y el view controller
    public var viewController : ViewController?

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        //pedir permiso al usuario para pedir notificaciones push
        registerForPushNotifications()
        
        
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    //crear funcion para las otificaciones
    func registerForPushNotifications(){
        //pedir permiso el usuario para recibir notificaciones
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]){
            granted, error in print("Permiso concerdido: \(granted)")
            
            guard granted else { return }
            
            self.getNotificationsSettings()
        }
        //.badge, .sound, .alert,
        // .carPlay, .provisional, .providesAppNotificationSettings
        // .criticalAlert,
        
        //define las acciones personalizas
        let acceptAction = UNNotificationAction(identifier: "ACCEPT_ACTION", title: "Acept", options: [.foreground])
        let declineAction = UNNotificationAction(identifier: "DECLINE_ACTION", title: "Decline", options: [.foreground])
        
        //define le tipo de notificacion
        let meetingInviteCatregory = UNNotificationCategory(identifier: "MEETIG_INVITATION", actions: [acceptAction, declineAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: .customDismissAction)
        
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.setNotificationCategories([meetingInviteCatregory])
    }
    
    func getNotificationsSettings(){
        UNUserNotificationCenter.current().getNotificationSettings{ settings in
            //comprobar los ajustes de las notificaciones de la app
        //print("configuracion push : \(settings)")
            
            //comprobamos que el usuario nos autoriza que le enviemos autorizaciones
            guard settings.authorizationStatus == .authorized else { return }
            
            //registrarlo en APNs
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            
        }
    }
    
    //si se ha completado el registro se ejecutara esta funcion
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map{ data in String(format: "%02.2hhx", data)}
        let token = tokenParts.joined()
        print("device token: \(token)")
    }
    
    //si se produce un error al tratar de registrar el dispositivo
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Failed to register: \(error)")

    }
    
    //los parametros de la notificación
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        guard let aps = userInfo["aps"] as? [String:AnyObject] else {
            completionHandler(.failed)
            return
            
        }
        print(aps)
        
        //la funcion extrae y muestra el mensaje si la app esta abierta
        notifMessaExtrat(aps: aps)
    }
    
    

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //obetener el meetID de la notificación (fuera de la apps)
        let userInfo = response.notification.request.content.userInfo
        //let meetID = userInfo["MEETING_ID"] as! String
        
        if let aps = userInfo["aps"] as? [String:AnyObject]{

            //la funcion extrae el mensaje de la notificacion si la app no esta en pantalla
            notifMessaExtrat(aps: aps)
            completionHandler()
        }
    }
    
    //esta funcion se encagar de extraer el mensaje de las notificaciones recibidas
    func notifMessaExtrat(aps: [String:AnyObject]){
        
        //modificar badge
        if let pushBadgeNumber:Int = aps["badge"] as? Int {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "BadgeChanged"), object: nil)
            UIApplication.shared.applicationIconBadgeNumber = pushBadgeNumber
        }
        
        //mostrar la notificacion en un alert
        let alertController = UIAlertController(title: aps["alert"] as? String, message: aps["alert"] as? String, preferredStyle: .alert)
        
        //extraigo el mensaje que nos trae la notificacion
        guard let arrg = aps["alert"] as? [String:AnyObject] else {
            //completionHandler(.failed)
            return
        }
        
        let mensajenotifi = arrg["body"] as! String
        viewController?.mensajes.append(["r", mensajenotifi])
        viewController?.tableView.reloadData()
    }
    
}

