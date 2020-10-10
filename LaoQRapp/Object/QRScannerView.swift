//
//  QRScannerView.swift
//  SerialEnrollment
//
//  Created by administrator on 2019/09/17.
//  Copyright © 2019 Akiko Shinozaki. All rights reserved.
//

import UIKit
import AVFoundation
import AudioToolbox


protocol QRScannerViewDelegate{
    func removeView()
    func getData(type:String, data:String)
}

class QRScannerView: UIView, AVCaptureMetadataOutputObjectsDelegate {
    
    var delegate:QRScannerViewDelegate?
    let session = AVCaptureSession()
    var videoLayer: AVCaptureVideoPreviewLayer?
    var serialNo : String!
    var cautionLabel:UILabel! = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 50))
    
    //var _serialList:[String] = []
    var _serialNo:String = ""
    
    @IBOutlet weak var baseView: UIView!
    @IBOutlet weak var preview: UIView!
    @IBOutlet weak var closeBtn: UIButton!

    override func draw(_ rect: CGRect) {
        // Drawing code
        closeBtn.addTarget(self, action: #selector(close), for: .touchUpInside)
        serialNo = ""
        // 入力（背面カメラ）
        let videoDevice = AVCaptureDevice.default(for: .video)!
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice)
        session.addInput(videoInput)
        
        // 出力（メタデータ）
        let metadataOutput = AVCaptureMetadataOutput()
        session.addOutput(metadataOutput)
        
        // QRコードを検出した際のデリゲート設定
        metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        // QRコードの認識を設定
        metadataOutput.metadataObjectTypes = [.qr,.ean13]
        
        // プレビュー表示
        videoLayer = AVCaptureVideoPreviewLayer.init(session: session)
        videoLayer?.frame = preview.bounds
        videoLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        
        //デバイスの向きとプレビューの向きを合わせる
        let orientation = UIDevice.current.orientation
        print(orientation.rawValue)
        switch orientation {
        case .portrait:
            videoLayer?.connection?.videoOrientation = .portrait
        case .landscapeLeft:
            videoLayer?.connection?.videoOrientation = .landscapeRight

        case .landscapeRight:
            videoLayer?.connection?.videoOrientation = .landscapeLeft

        default:
            break
        }
        
        // 端末回転の通知機能を設定します。
        let name = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.addObserver(self, selector: #selector(orientationDidChange(_:)), name: name, object: nil)
        
        baseView.layer.cornerRadius = 8.0
        baseView.clipsToBounds = true
        
        preview.layer.addSublayer(videoLayer!)
        
        //cautionLabelの設定
        cautionLabel.frame = CGRect(x: 0, y: 20, width: preview.frame.size.width, height: 30)
        cautionLabel.font = UIFont.boldSystemFont(ofSize: 20)
        cautionLabel.textAlignment = .center
        cautionLabel.textColor = UIColor.yellow
        cautionLabel.backgroundColor = UIColor.clear
        cautionLabel.text = ""
        
        preview.addSubview(cautionLabel)
        cautionLabel.isHidden = true
        
        session.startRunning()
        
    }
    
    //コードから生成したときに通る初期化処理
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.nibInit()
    }
    
    // ストーリーボードで配置した時の初期化処理
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.nibInit()
    }
    
    // xibファイルを読み込んでviewに重ねる
    fileprivate func nibInit() {
        // File's OwnerをXibViewにしたので ownerはself になる
        guard let view = UINib(nibName: "QRScannerView", bundle: nil).instantiate(withOwner: self, options: nil).first as? UIView else {
            return
        }
        
        view.frame = self.bounds
        self.addSubview(view)
        
    }
    
    
    func metadataOutput(_ captureOutput: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 複数のメタデータを検出
        for metadata in metadataObjects as! [AVMetadataMachineReadableCodeObject] {
            // QRコードのデータかどうかの確認
            if metadata.type == .qr {
                if metadata.stringValue != nil {
                    // 検出データを取得
                    let QRdata = metadata.stringValue!
                    //特定の文字列が含まれていないと認識しない
                    //print(QRdata)
                    
                    let hantei = SerialNumber.make(QRdata)
                    if hantei.isSerial {
                        _serialNo = hantei.serialNo
                        AudioServicesPlaySystemSound(1000)
                        cautionLabel.isHidden = true
                        self.session.stopRunning()
                        delegate?.getData(type:"QR",data: _serialNo)
                        self.close()
                        
                    }else {
                        cautionLabel.isHidden = false
                        cautionLabel.text = "シリアル番号を読み取ってください"
                    }
                    
                }
            }else if metadata.type == .ean13 {
                //EAN13の時・・・プライスカード
                // 検出データを取得
                let result = metadata.stringValue!

                //読み込んだコードがプライスカードの書式かどうかチェックする(1,5,6文字目が「2,0,0」)
                let strArr = Array(result).map{String($0)}
                let check = strArr[0]+strArr[4]+strArr[5]
                print(check)
                
                if check == "200" || result.hasPrefix("2300") {
                    //check:200 生産品, result:2300 リフレッシュのTAG
                    AudioServicesPlaySystemSound(1106)
                    AudioServicesPlaySystemSound(4095) //バイブ(iPhoneのみ)
                    
                    cautionLabel.isHidden = true
                    self.session.stopRunning()
                    delegate?.getData(type:"EAN13",data: result)
                    self.close()
                
                    
                }else {
                    cautionLabel.isHidden = false
                    cautionLabel.text = "このバーコードは認識できません"
                }
                
            //QR・EAN13ではなかった時
            }else {
                cautionLabel.isHidden = false
                cautionLabel.text = "読み取りできません"
            }
        }
    }
    
    
    @objc func orientationDidChange(_ notification: NSNotification) {

        //デバイスの向きとプレビューの向きを合わせる
            let orientation = UIDevice.current.orientation
            //print(orientation.rawValue)
            switch orientation {
            case .portrait:
                videoLayer?.connection?.videoOrientation = .portrait
            case .landscapeLeft:
                videoLayer?.connection?.videoOrientation = .landscapeRight

            case .landscapeRight:
                videoLayer?.connection?.videoOrientation = .landscapeLeft

            default:
                break
            }
        
       }
    
    
    @objc func close() {
        // 端末回転の通知機能の設定を解除します。
        let name = UIDevice.orientationDidChangeNotification
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
        
        session.stopRunning()
        delegate?.removeView()
        self.removeFromSuperview()
    }

}
