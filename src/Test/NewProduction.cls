Class Test.NewProduction Extends Ens.Production
{

XData ProductionDefinition
{
<Production Name="Test.NewProduction" LogGeneralTraceEvents="false">
  <Description></Description>
  <ActorPoolSize>2</ActorPoolSize>
  <Item Name="Test.BS.ImportMaster" Category="" ClassName="Test.BS.ImportMaster" PoolSize="1" Enabled="false" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="ArchivePath">c:\import\products\archive</Setting>
    <Setting Target="Adapter" Name="FilePath">\\192.168.0.35\share\in</Setting>
    <Setting Target="Host" Name="Credentials">WINUSER</Setting>
  </Item>
  <Item Name="FileServer連携" Category="" ClassName="Test.BS.ImportMaster" PoolSize="1" Enabled="true" Foreground="false" Comment="" LogTraceEvents="false" Schedule="">
    <Setting Target="Adapter" Name="ArchivePath">C:\import\products\archive</Setting>
    <Setting Target="Adapter" Name="FilePath">\\192.168.0.35\share\in</Setting>
    <Setting Target="Host" Name="Credentials">WINUSER</Setting>
  </Item>
</Production>
}

}
