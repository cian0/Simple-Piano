package {import flash.display.Sprite;import flash.events.SampleDataEvent;import flash.media.Sound;import flash.media.SoundChannel;import flash.events.KeyboardEvent;import flash.ui.Keyboard;import flash.events.MouseEvent;import flash.utils.setTimeout;import flash.text.TextField;import flash.text.TextFormat;import flash.filters.GlowFilter;import flash.filters.DropShadowFilter;
[SWF(backgroundColor="0xf4f4f4", width="530", height="220")]
/**2011 Phlashers.com 5KB Challenge entry by Ian Icasiano, @ cyril.icasiano@gmail.com**/
	public class SimplePiano extends Sprite {
		var snd:Sound,samples:Number=2049;
		var keyDwn:Vector.<Boolean>=new Vector.<Boolean>(300,true);
		var regKeys:Vector.<uint>=new Vector.<uint>();
		var pressd:Vector.<Vector.<Number>> = new Vector.<Vector.<Number>>(500, true);
		var ctrl:Vector.<uint>=new Vector.<uint>(200,true);
		var sndsArr:Vector.<Number>=new Vector.<Number>();
		const TWO_PI:Number = 2*Math.PI,PI2_OVR_SR:Number=TWO_PI/44100;
		var keys:Array = new Array();
		var ctrls:Array = [90,83,88,68,67,86,71,66,72,78,74,77,69,52,82,53,84,89,55,85,56,73,57,79,80];//keycodes
  		function SimplePiano(){
			sndsArr.push(65.41);//initialize sounds base at 65.41Hz
			for (var i:uint = 1; i <61; i++)sndsArr.push(sndsArr[i-1] * 1.0594630943593);
			for (var c:uint=25;c<50;c++){
				var ct:uint=c-25; ctrl[ctrls[ct]]=c;//choose only notes from C3 to C5
			}
			stage.addEventListener(KeyboardEvent.KEY_DOWN,dwnLstnr);
			stage.addEventListener(KeyboardEvent.KEY_UP,upLstnr);
 			snd = new Sound();snd.addEventListener(SampleDataEvent.SAMPLE_DATA, writeData);snd.play();
			var jump:uint = 3,nextJump:uint=2,keyCtr:uint= 0;
			for (var ctr:uint = 0; ctr < 15; ctr++){//15 white keys
				var spr:Sprite;
				spr = createKey(keyCtr,34,200,Math.random()*0xFFFFFF);
				spr.x = 10 + spr.width*ctr;spr.y = 10;
				keys.push(spr);keyCtr++;addChildAt(spr,0);
				if (ctr == nextJump){
					(jump==3)?jump=4:(jump==4)?jump=3:jump;
					nextJump +=jump;
				}else if (ctr != 14){//10 black keys
					spr = createKey(keyCtr,17,120,0x000000);
					spr.x = Sprite(keys[keys.length-1]).x + (spr.width *1.5);spr.y = 10;
					keys.push(spr);keyCtr++;addChild(spr);
				}
			}
 		}
		function createKey(indx:uint=-1,kW:uint=0,kH:uint=0,keyC:uint=0):Sprite{
			var spr:Sprite,tF:TextField=new TextField(),tFmt:TextFormat=new TextFormat(),bevel:DropShadowFilter=new DropShadowFilter();
			var sg:*;
			spr = new Sprite();sg = spr.graphics;
			sg.beginFill(keyC);sg.drawRoundRect(0,0,kW,kH,10,10);sg.endFill();
			spr.width = kW; spr.height = kH;spr.buttonMode = true;
			tF.text = String.fromCharCode(ctrls[indx]);
			tF.width = spr.width;tF.height = 20;tF.y =spr.height- 20;
			tFmt.align = "center"; tFmt.color = 0xffffff; tF.setTextFormat(tFmt); tF.selectable = false;
			tF.filters = [bevel];
			spr.addChild(tF);
			spr.mouseChildren=false;
			spr.addEventListener(MouseEvent.CLICK, clckd);
			return (spr);
		}
		function clckd(e:MouseEvent){
			var ctr:uint = 0;
			for each(var key:Sprite in keys){
				if (Sprite(e.target) == key){
					prss(ctrl[ctrls[ctr]], ctrls[ctr]);
					setTimeout(function (){unprss(ctrl[ctrls[ctr]],  ctrls[ctr]);}, 500);
					break;
				}
				ctr++
			}
		}
		function anyKyDwn():Boolean{
			for (var ctr:uint = 0; ctr < 300; ctr++)
				if (keyDwn[ctr])return (true);
			return (false);
		}
		function upLstnr(e:KeyboardEvent) {
			var k:uint=e.keyCode, ct:uint=ctrl[k];
			keyDwn[k] = false;
			(ct!=0)?unprss(ct,k):k;
			if (!anyKyDwn()&& regKeys.length > 0)
				for each(var val:Number in regKeys) unprss(val);
		}
		function dwnLstnr(e:KeyboardEvent){
			var k:uint=e.keyCode, ct:uint=ctrl[k];
			keyDwn[k] = true;
			if (ct!= 0 && regKeys.indexOf(ct) == -1)prss(ct,k);
		}
		function unprss(kN:uint, keyCode:Number = -1){
			var id:*;
			id=keys[ctrls.indexOf(keyCode)];
			(id!=null)?id.filters =[]:null;
			id=regKeys.indexOf(kN);
			(id!=-1)?regKeys.splice(id,1):null;
			if (pressd[kN]== null)
				return;
			pressd[kN][0] = null;pressd[kN][1] = null;pressd[kN] = null;
		}
		function prss(kN:uint, keyCode:Number=-1):void{
			var fil:GlowFilter = new GlowFilter();
			Sprite(keys[ctrls.indexOf(keyCode)]).filters = [fil];
			if (regKeys.length >2)return;
			if (pressd[kN]!=null)return;
			pressd[kN] = new Vector.<Number>(2);
			pressd[kN][0] = sndsArr[kN -1];
			pressd[kN][1] = new Number();
			regKeys.push(kN);
		}
		function writeData(e:SampleDataEvent){
			var amp:Number = 0.075, sample:Number, amplitude:Number = 0,rk:*;
			for(var i:Number = 0; i<samples; i++){
				for each (var registeredKey:Number in regKeys){
					rk=pressd[registeredKey];
					if (rk!=null){
						sample =rk[1]<Math.PI?amp:-amp;
						rk[1]+=PI2_OVR_SR*rk[0];
						rk[1]=rk[1]<TWO_PI?rk[1]:rk[1]-TWO_PI;//create a square wave for each pressed key.
						amplitude += sample;
					}
				}
				e.data.writeFloat((amplitude)/18);//32 bit for left and right
				e.data.writeFloat((amplitude)/18);
			}
		}
 	}
}