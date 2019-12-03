//
//  GameManeger.swift
//  Fishing_Demo
//
//  Created by Tasuku Kubo on 2019/11/29.
//  Copyright © 2019 Spike. All rights reserved.
//

import ARKit
import Foundation
import CoreMotion

//timer
class GameManager{
    
}
class GameStatus{
    //魚の情報<かかった瞬間に決定される(未実装)
    //かかり具合<-智章が書き換える　＜＜ケンタが参照
    var HitCondition:Int=0
    //釣れたか釣れてないか <- ケンタが決定
    var FightResult:Bool=true
}

class GameScene {
    init(status:GameStatus){
        self.status=status
    }
    var status : GameStatus
    func tap(){}
    func release(){}
    func update(cameraNode:SCNNode,acc:SCNVector3,gyro:SCNVector3){
        fatalError()
    }
}


class Visualizer{
    //平面ノードの位置
    //平面までの距離を返す関数
    //BaseNode(child:float,plane)
    //anchorの位置にBaseNodeを移動
    //rendererからVisualizerを呼び出す(BaseNode の移動)
    //SceneNodeのrootNodeにadd
    
    init(){
        let objGeometry = SCNSphere(radius: 0.05)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        material.diffuse.intensity = 0.8;
        objGeometry.materials = [material]
        floatNode=SCNNode(geometry: objGeometry)
    }
    //Is it required to write the sceneView in here？
    //If not, where the sceneView should be written in?
    
    //This is the function to get camera position and to define the initial position of floatNode
    //This function requires the camera position as Index(World coordinates)
    
    //移動する距離を引数にする. vを利用して上手いこと移動
    
    func moveFloat(how pos:SCNVector3){
        //if文で足した分だけ移動したか判定
        //移動してたらv=0
        //何秒でその値を移動したいかが必要(0.5秒->1/30)
        floatVel.x = pos.x/30
        floatVel.y = pos.y/30
        floatVel.z = pos.z/30
    }
    //target まで移動(updateを使用)
    func setInitialPos(to campos:SCNVector3){
        floatNode.position = campos
    }
    
    func setFloatVel(_ vel:SCNVector3){
        floatVel = vel
    }
    //It is unimplemented to calculate gravity yet
    //必要な移動が終了した時にV=0
    func update(){
        let newx = floatPos.x + floatVel.x * 0.01
        let newy = floatPos.y + floatVel.y * 0.01
        let newz = floatPos.z + floatVel.z * 0.01
        floatNode.position = SCNVector3(newx,newy,newz)
    }
    var floatPos:SCNVector3{get{return floatNode.position}}
    let floatNode:SCNNode
    var floatVel=SCNVector3(0,0,0)
}

class Casting:GameScene{
    let visual = Visualizer()
    var campos=SCNVector3(0,0,0)
    var vel=SCNVector3(0,0,0)
    //func collision is needed
    //The Visualizer manages the velocity of the float
    //This class has to pass the initial posision and velocity of the float to the visualizer
    override func update(cameraNode: SCNNode, acc: SCNVector3, gyro: SCNVector3) {
        vel = acc
        campos = cameraNode.convertPosition(SCNVector3(0,0,0),to:nil)
    }
    
    func collision(){
        // return  the flag which means wheather collide or not
    }
    
    override func release(){
        visual.setInitialPos(to:campos)
        visual.setFloatVel(vel)
    }
}
//ここから仲西
/*
let cl = Hooking()
cl.FloatShinker()
*/
class Hooking:GameScene{
    //let visual=Vizualizer()
    override func update(cameraNode:SCNNode,acc:SCNVector3,gyro:SCNVector3){
        accHook = acc//using accHook.Z
        gryroHook = gyro//using gryroHook.X
    }
    
    var accHook = SCNVector3(0,0,0)
    var gryroHook = SCNVector3(0,0,0)
    var gyroX:Float = 0
    var accZ:Float = 0
    var seccount:Float = 0
    var WaitTime = Double.random(in: 1 ... 10)// 1から10を生成
    var calval:Float = 0
    var sendval:Int = 0
    
    //フッキングの判定と返す値を決定する関数
    func Hookngresult() {
        //intervalSeconds * 10 = 取得可能時間
        //判定時間　0.03(位置の取得の更新)*16(カウンタ数) = 約0.5 秒
        if (seccount > 16){
            
            
            
            //計測の終了をGameManagerに通知(位置の取得{CMMotionManager}を終了させる。)
            
            
            
            accZ = abs(accZ)//accZは負の値なので計算しやすいように正の値に変換する。
            
            /*
            //桁数が多いので四捨五入してみる(使いたいなら)
            gyroX = round(gyroX) / 1000
            accZ = round(accZ) / 1000
            print("取得したgyroXの値は \(gyroX) です")
            print("取得したaccZの値は \(accZ) です")
            print("取得したsendvalの値は \(sendval) です")
            */
            
            //取得した値を掛け算する
            calval = gyroX * accZ
            
            
            switch calval {
                case 0..<10:// 0から10未満。
                    sendval = 1
                case 10..<30:
                    sendval = 2
                case 30..<50:
                    sendval = 3
                case 50..<70:
                    sendval = 4
                case 70..<90:
                    sendval = 5
                case 90..<110:
                    sendval = 6
                case 110..<130:
                    sendval = 7
                case 130..<140:
                    sendval = 8
                case 140..<150:
                    sendval = 9
                case 150..<1000000:
                    sendval = 10
            default://0(動かしていない)の時や、予期せぬ値
              sendval = 0
            }
            //Gamestatusに値を引き渡す。(classの処理が全て終了)
            status.HitCondition = sendval
            //print("判定終了 受け渡す値は\(sendval)です")
        }else{
            //画面上の動き(acc_z)が上向き(-Z方向),画面の回転(gyro_x)が手前側(+X方向)の時に値を取得する。
            if (gryroHook.x >= 0 && accHook.z <= 0){
                gyroX += gryroHook.x
                accZ += accHook.z
                seccount += 1
            } else if (gryroHook.x < 0 && accHook.z <= 0){
                //accZのみが正しい値の場合
                accZ += accHook.z
                seccount += 1
            } else if (gryroHook.x >= 0 && accHook.z > 0){
                //gyroXが正しい値の場合
                gyroX += gryroHook.x
                seccount += 1
            } else {
                //逆方向の判定が入った場合はカウンタの半分の値のみ追加する。
                seccount += 0.5
            }
            //print(gyroX)
            //print(accZ)
        }
    }
    
    //ウキが沈む
    func FloatShinker(){
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + WaitTime) {
            //GameMnanagerにウキが沈んだことを伝える。(ウキが沈むというアクション)
            //Vizualizerにウキをどのくらい沈めたいかを通知
            //低音を流して振動で掛かったことを伝える。
            print("＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋魚が掛かった＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋＋")
            //ここで魚の情報が決定する。
            self.Hookngresult()
        }
    }
}


