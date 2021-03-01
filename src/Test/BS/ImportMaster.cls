/// マスターデータのインポート
/// 
///  CSVファイルにある商品情報を読み込むルーチンを呼び出す
Class Test.BS.ImportMaster Extends Ens.BusinessService [ Language = objectscript ]
{

/// 共有アクセス用Credential
Property Credentials As %String;

/// 　ビジネスサービスにてCredentialを選択させるUIを指定
Parameter SETTINGS = "Credentials:Basic:credentialsSelector";

Parameter ADAPTER = "EnsLib.File.InboundAdapter";

/// ファイルを検知した際の処理
Method OnProcessInput(pInput As %Stream.Object, Output pOutput As %RegisteredObject) As %Status
{
	// 検知したファイルのファイル名を取得
	set filename=pInput.Attributes("Filename")
	
	// 商品情報を読み込むルーチンを呼び出す
	do ImportData^Products(filename)
	Quit $$$OK
}

/// This user callback method is called via initConfig() from %OnNew() or in the case of SOAP Services from OnPreSOAP()
Method OnInit() As %Status
{
	// ファイルパスが\\で始まる場合でかつCredentialsプロパティが空文字でなければ、共有ディレクトリに接続
	if $extract(..Adapter.FilePath,1,2)="\\"&&(..Credentials'="") {

		// 認証情報を検索
		set tCredential=##class(Ens.Config.Credentials).%OpenId(..Credentials)
		if '$isobject(tCredential) { 
			 // プロパティCredentialsに入力された認証情報が存在しない場合、終了
			 Set tSC=$$$EnsError($$$EnsErrNoCredentials,..Credentials) Quit tSC
		}
		// 共有ディレクトリへの接続
		set tSC=..ExecNetUse($piece(..Adapter.FilePath,"\",1,4),tCredential.Username,tCredential.Password)
		if $$$ISERR(tSC) {
			$$$LOGSTATUS(tSC)
			
			// エラーが発生した場合、念のため共有ディレクトリの切断
			set tSC2=..ExecNetUse($piece(..Adapter.FilePath,"\",1,4),,,1)
			if $$$ISERR(tSC2) $$$LOGSTATUS(tSC2)

			// エラーを正しく伝える
			set %objlasterror=tSC
			quit tSC
		}

		$$$LOGINFO("共有ディレクトリ "_$piece(..Adapter.FilePath,"\",1,4)_" に接続しました")
	}
	Quit $$$OK
}

/// This user callback method is called from %OnClose()
Method OnTearDown() As %Status
{
	// 共有ディレクトリの切断
	set tSC=..ExecNetUse($piece(..Adapter.FilePath,"\",1,4),,,1)
	if $$$ISERR(tSC) $$$LOGSTATUS(tSC)
	if $$$ISOK(tSC)	$$$LOGINFO("共有ディレクトリ "_$piece(..Adapter.FilePath,"\",1,4)_" を切断しました")

	// 継承元の処理を実行
	quit ##super()
}

/// Net use コマンドの実行
/// sharefolder ... 共有フォルダ名 (ex. \\hostname\sharename)
/// username ... リモートにアクセスするユーザ名 (ex. hostname\username)
/// password ... ユーザ名に対するパスワード
/// deleteflg ... 切断フラグ
///         0 ... 接続
///         1 ... 切断
ClassMethod ExecNetUse(sharefolder As %String, username As %String = "", password As %String = "", deleteflg As %Boolean = 0) As %Status
{
	// エラーログファイル名を取得
	set curdir=$SYSTEM.Process.CurrentDirectory()
	set errlog=curdir_"netuse_"_$job_".log"

	set tSC=$$$OK
	try {
		if deleteflg {
			// Net useコマンドで切断する
			set sts=$zf(-1,"net use "_sharefolder_" /delete 2> """_errlog_"""")
		} else {
			// Net useコマンドで指定されたユーザ名、パスワードで接続する
			set sts=$zf(-1,"net use "_sharefolder_" "_password_$select(username'="":" /user:"_username,1:"")_" /persistent:NO  2> """_errlog_"""")
		}
		quit:sts=0  // 正常終了ならば終了

		// ログの読み込み
		set stream=##class(%FileCharacterStream).%New()
		set stream.Filename=errlog
		set msg=$translate(stream.Read(),$char(10,13)," ") // 改行コードを消去
		kill stream
		
		set tSC=$$$ERROR(5001,"net use コマンドでエラーが発生しました 戻り値="_sts_" Msg="_msg)
	} catch {
		set tSC=$$$ERROR(5001,"net use コマンド実行時にエラーが発生しました Err="_$zerror)
	}
	// ログファイルの削除
	do ##class(%File).Delete(errlog)
	quit tSC
}

}
