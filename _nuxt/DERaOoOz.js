import{c as n,H as Q,s as ee,J as U,K as Z,a2 as ve,ae as ne,L as pe,x as ue,af as me,ag as be,ad as Y,d as K,D as X,a as x,o as p,b,m as F,j as R,t as L,h as e,n as D,S as q,V as ye,T as ge,W as le,$ as de,G as ie,f as A,g as E,l as O,F as J,X as _e,N as te,ah as re,ai as he,aj as Be,Z as xe,C as Fe,E as Se,a1 as Ce,aa as Ne}from"./mpN_Lbkf.js";import{a as oe}from"./D8PeNSKa.js";const ce=(t,s)=>n(()=>{const l=Q(t),a=Q(s);return l===!0?"true":typeof l=="string"?l:a===!1?"true":l===!1?"false":void 0}),fe=t=>n(()=>{const s=Q(t);return s===!0?"is-valid":s===!1?"is-invalid":null}),ke=(t,s)=>{if(t===null)return;let l=t;if(s.number&&typeof l=="string"&&l!==""){const a=Number.parseFloat(l);l=Number.isNaN(a)?l:a}return l},Ie=(t,s,l,a)=>{var d;const r=ee(0),i=U(()=>t.id,"input"),h=Z(()=>t.debounce??0),I=Z(()=>t.debounceMaxWait??NaN),f=(d=ve(ne,null))==null?void 0:d(i),$=n(()=>t.state!==void 0?t.state:(f==null?void 0:f.state.value)??null),y=ce(()=>t.ariaInvalid,$),S=fe($),V=be(o=>{l.value=o},()=>a.lazy===!0?0:h.value,{maxWait:()=>a.lazy===!0?NaN:I.value}),w=(o,c=!1)=>{a.lazy===!0&&c===!1||V(o)},{focused:C}=pe(s,{initialValue:t.autofocus}),v=(o,c,_=!1)=>t.formatter!==void 0&&(!t.lazyFormatter||_)?t.formatter(o,c):o;return ue(()=>{var o;s.value&&(s.value.value=((o=l.value)==null?void 0:o.toString())??"")}),me(()=>{Y(()=>{t.autofocus&&(C.value=!0)})}),{input:s,computedId:i,computedAriaInvalid:y,onInput:o=>{const{value:c}=o.target,_=v(c,o);if(o.defaultPrevented){o.preventDefault();return}w(_)},onChange:o=>{const{value:c}=o.target,_=v(c,o);if(o.defaultPrevented){o.preventDefault();return}const P=_;l.value!==P&&w(_,!0)},onBlur:o=>{if(!a.lazy&&!t.lazyFormatter&&!a.trim)return;const{value:c}=o.target,_=v(c,o,!0),P=a.trim?_.trim():_,j=P.length!==_.length;l.value!==P&&w(_,!0),a.trim&&j&&(r.value=r.value+1)},focus:()=>{t.disabled||(C.value=!0)},blur:()=>{t.disabled||(C.value=!1)},forceUpdateKey:r,stateClass:S}},we=K({__name:"BFormInvalidFeedback",props:{ariaLive:{default:void 0},forceShow:{type:Boolean,default:!1},id:{default:void 0},role:{default:void 0},state:{type:[Boolean,null],default:null},tag:{default:"div"},text:{default:void 0},tooltip:{type:Boolean,default:!1}},setup(t){const l=X(t,"BFormInvalidFeedback"),a=n(()=>l.forceShow===!0||l.state===!1),d=n(()=>({"d-block":a.value,"invalid-feedback":!l.tooltip,"invalid-tooltip":l.tooltip}));return(r,i)=>(p(),x(q(e(l).tag),{id:e(l).id,role:e(l).role,"aria-live":e(l).ariaLive,"aria-atomic":e(l).ariaLive?!0:void 0,class:D(d.value)},{default:b(()=>[F(r.$slots,"default",{},()=>[R(L(e(l).text),1)])]),_:3},8,["id","role","aria-live","aria-atomic","class"]))}}),$e=K({__name:"BFormRow",props:{tag:{default:"div"}},setup(t){const l=X(t,"BFormRow");return(a,d)=>(p(),x(q(e(l).tag),{class:"row d-flex flex-wrap"},{default:b(()=>[F(a.$slots,"default")]),_:3}))}}),Ve=K({__name:"BFormText",props:{id:{default:void 0},inline:{type:Boolean,default:!1},tag:{default:"small"},text:{default:void 0},textVariant:{default:"body-secondary"}},setup(t){const l=X(t,"BFormText"),a=ye(l),d=n(()=>[a.value,{"form-text":!l.inline}]);return(r,i)=>(p(),x(q(e(l).tag),{id:e(l).id,class:D(d.value)},{default:b(()=>[F(r.$slots,"default",{},()=>[R(L(e(l).text),1)])]),_:3},8,["id","class"]))}}),ze=K({__name:"BFormValidFeedback",props:{ariaLive:{default:void 0},forceShow:{type:Boolean,default:!1},id:{default:void 0},role:{default:void 0},state:{type:[Boolean,null],default:null},tag:{default:"div"},text:{default:void 0},tooltip:{type:Boolean,default:!1}},setup(t){const l=X(t,"BFormInvalidFeedback"),a=n(()=>l.forceShow===!0||l.state===!0),d=n(()=>({"d-block":a.value,"valid-feedback":!l.tooltip,"valid-tooltip":l.tooltip}));return(r,i)=>(p(),x(q(e(l).tag),{id:e(l).id,role:e(l).role,"aria-live":e(l).ariaLive,"aria-atomic":e(l).ariaLive?!0:void 0,class:D(d.value)},{default:b(()=>[F(r.$slots,"default",{},()=>[R(L(e(l).text),1)])]),_:3},8,["id","role","aria-live","aria-atomic","class"]))}}),se=(t,s)=>s+(t?Be(t):""),Ae={key:0,ref:"_content",class:"form-floating"},He=K({__name:"BFormGroup",props:{contentCols:{type:[Boolean,String,Number],default:void 0},labelCols:{type:[Boolean,String,Number],default:void 0},labelAlign:{default:void 0},ariaInvalid:{type:[Boolean,String],default:void 0},description:{default:void 0},disabled:{type:Boolean,default:!1},feedbackAriaLive:{default:"assertive"},floating:{type:Boolean,default:!1},id:{default:void 0},invalidFeedback:{default:void 0},label:{default:void 0},labelClass:{default:void 0},labelFor:{default:void 0},labelSize:{default:void 0},labelVisuallyHidden:{type:Boolean,default:!1},state:{type:[Boolean,null],default:null},tooltip:{type:Boolean,default:!1},validFeedback:{default:void 0},validated:{type:Boolean,default:!1},contentColsSm:{type:[Boolean,String,Number],default:void 0},contentColsMd:{type:[Boolean,String,Number],default:void 0},contentColsLg:{type:[Boolean,String,Number],default:void 0},contentColsXl:{type:[Boolean,String,Number],default:void 0},labelColsSm:{type:[Boolean,String,Number],default:void 0},labelColsMd:{type:[Boolean,String,Number],default:void 0},labelColsLg:{type:[Boolean,String,Number],default:void 0},labelColsXl:{type:[Boolean,String,Number],default:void 0},labelAlignSm:{default:void 0},labelAlignMd:{default:void 0},labelAlignLg:{default:void 0},labelAlignXl:{default:void 0}},setup(t){const s=["input","select","textarea"],a=X(t,"BFormGroup"),d=ge(),r=le(),i=le(),h=de(()=>a.state),I=ee([]);xe(ne,m=>(I.value=[m],{state:h}));const f=n(()=>a.labelFor!==void 0?a.labelFor:I.value[0]&&I.value[0].value?I.value[0].value:null),$=["xs","sm","md","lg","xl"],y=(m,N)=>$.reduce((k,B)=>{const G=se(B==="xs"?"":B,`${N}Cols`);let u=m[G];if(u=u===""?!0:u||!1,typeof u!="boolean"&&u!=="auto"){const ae=Number.parseInt(u);u=Number.isNaN(ae)?0:ae,u=u>0?u:!1}return u&&(B==="xs"?k[typeof u=="boolean"?"col":"cols"]=u:k[B||(typeof u=="boolean"?"col":"cols")]=u),k},{}),S=ie("_content"),V=n(()=>y(a,"content")),w=n(()=>((m,N)=>$.reduce((k,B)=>{const G=se(B==="xs"?"":B,`${N}Align`),u=m[G]||null;return u&&(B==="xs"?k.push(`text-${u}`):k.push(`text-${B}-${u}`)),k},[]))(a,"label")),C=n(()=>y(a,"label")),v=n(()=>Object.keys(V.value).length>0||Object.keys(C.value).length>0),M=fe(h),W=ce(()=>a.ariaInvalid,h),H=m=>{if(f.value||S.value===null)return;const{target:N}=m,k=N?N.tagName:"";if([...s,"a","button","label"].indexOf(k)!==-1)return;const B=[...S.value.querySelectorAll(s.map(u=>`${u}:not([disabled])`).join())].filter(re),[G]=B;B.length===1&&G instanceof HTMLElement&&he(G)},z=U(()=>a.id),g=U(void 0,"_BV_label_"),o=n(()=>f.value?"label":"legend"),c=n(()=>[v.value?"col-form-label":"form-label",{"bv-no-focus-ring":!f.value,"col-form-label":v.value||!f.value,"pt-0":!v.value&&!f.value,"d-block":!v.value&&f.value,[`col-form-label-${a.labelSize}`]:!!a.labelSize,"visually-hidden":a.labelVisuallyHidden},w.value,a.labelClass]),_=U(void 0,"_BV_feedback_invalid_"),P=U(void 0,"_BV_feedback_valid_"),j=U(void 0,"_BV_description_"),T=n(()=>!f.value);return(m,N)=>(p(),x(q(T.value?"fieldset":"div"),{id:e(z),disabled:T.value?e(a).disabled:null,role:T.value?null:"group","aria-invalid":e(W),"aria-labelledby":T.value&&v.value?e(g):null,class:D([[e(M),{"was-validated":e(a).validated}],"b-form-group"])},{default:b(()=>[A(e(i).define,null,{default:b(()=>[d["invalid-feedback"]||e(a).invalidFeedback?(p(),x(we,{key:0,id:e(_),"aria-live":e(a).feedbackAriaLive,state:h.value,tooltip:e(a).tooltip},{default:b(()=>[F(m.$slots,"invalid-feedback",{},()=>[R(L(e(a).invalidFeedback),1)])]),_:3},8,["id","aria-live","state","tooltip"])):O("",!0),d["valid-feedback"]||e(a).validFeedback?(p(),x(ze,{key:1,id:e(P),"aria-live":e(a).feedbackAriaLive,state:h.value,tooltip:e(a).tooltip},{default:b(()=>[F(m.$slots,"valid-feedback",{},()=>[R(L(e(a).validFeedback),1)])]),_:3},8,["id","aria-live","state","tooltip"])):O("",!0),d.description||e(a).description?(p(),x(Ve,{key:2,id:e(j)},{default:b(()=>[F(m.$slots,"description",{},()=>[R(L(e(a).description),1)])]),_:3},8,["id"])):O("",!0)]),_:3}),A(e(r).define,null,{default:b(()=>[d.label||e(a).label||v.value?(p(),E(J,{key:0},[v.value?(p(),x(oe,_e(te({key:0},C.value)),{default:b(()=>[(p(),x(q(o.value),{id:e(g),for:f.value||null,tabindex:T.value?"-1":null,class:D(c.value),onClick:N[0]||(N[0]=k=>T.value?H:null)},{default:b(()=>[F(m.$slots,"label",{},()=>[R(L(e(a).label),1)])]),_:3},8,["id","for","tabindex","class"]))]),_:3},16)):(p(),x(q(o.value),{key:1,id:e(g),for:f.value||null,tabindex:T.value?"-1":null,class:D(c.value),onClick:N[1]||(N[1]=k=>T.value?H:null)},{default:b(()=>[F(m.$slots,"label",{},()=>[R(L(e(a).label),1)])]),_:3},8,["id","for","tabindex","class"]))],64)):O("",!0)]),_:3}),v.value?(p(),x($e,{key:0},{default:b(()=>[A(e(r).reuse),A(oe,te(V.value,{ref:"_content"}),{default:b(()=>[F(m.$slots,"default",{id:e(z),ariaDescribedby:null,descriptionId:e(j),labelId:e(g)}),A(e(i).reuse)]),_:3},16)]),_:3})):(p(),E(J,{key:1},[e(a).floating&&!v.value?(p(),E("div",Ae,[F(m.$slots,"default",{id:e(z),ariaDescribedby:null,descriptionId:e(j),labelId:e(g)}),A(e(r).reuse),A(e(i).reuse)],512)):(p(),E(J,{key:1},[A(e(r).reuse),F(m.$slots,"default",{id:e(z),ariaDescribedby:null,descriptionId:e(j),labelId:e(g)}),A(e(i).reuse)],64))],64))]),_:3},8,["id","disabled","role","aria-invalid","aria-labelledby","class"]))}}),Me=(t,s)=>{const l=ee(0),a=Ne(de(s)),d=Z(()=>a.value.maxRows||NaN,{method:"parseInt",nanToZero:!0}),r=Z(()=>a.value.rows||NaN,{method:"parseInt",nanToZero:!0}),i=n(()=>Math.max(r.value||2,2)),h=n(()=>Math.max(i.value,d.value||0)),I=n(()=>i.value===h.value?i.value:null),f=async()=>{if(!t.value||!re(t.value)){l.value=null;return}const y=getComputedStyle(t.value),S=Number.parseFloat(y.lineHeight)||1,V=(Number.parseFloat(y.borderTopWidth)||0)+(Number.parseFloat(y.borderBottomWidth)||0),w=(Number.parseFloat(y.paddingTop)||0)+(Number.parseFloat(y.paddingBottom)||0),C=V+w,v=S*i.value+C,M=t.value.style.height||y.height;l.value="auto",await Y();const{scrollHeight:W}=t.value;l.value=M,await Y();const H=Math.max((W-w)/S,2),z=Math.min(Math.max(H,i.value),h.value),g=Math.max(Math.ceil(z*S+C),v);if(a.value.noAutoShrink&&(Number.parseFloat(M.toString())||0)>g){l.value=M;return}l.value=`${g}px`};ue(f);const $=n(()=>({resize:"none",height:typeof l.value=="string"?l.value:l.value?`${l.value}px`:void 0}));return{onInput:f,computedStyles:$,computedRows:I}},Te=["id","name","form","value","disabled","placeholder","required","autocomplete","readonly","aria-required","aria-invalid","rows","wrap"],Pe=K({__name:"BFormTextarea",props:Fe({noResize:{type:Boolean,default:!1},rows:{default:2},wrap:{default:"soft"},noAutoShrink:{type:Boolean,default:!1},maxRows:{default:void 0},ariaInvalid:{type:[Boolean,String],default:void 0},autocomplete:{default:void 0},autofocus:{type:Boolean,default:!1},disabled:{type:Boolean,default:!1},form:{default:void 0},formatter:{type:Function,default:void 0},id:{default:void 0},lazyFormatter:{type:Boolean,default:!1},list:{default:void 0},name:{default:void 0},placeholder:{default:void 0},plaintext:{type:Boolean,default:!1},readonly:{type:Boolean,default:!1},required:{type:Boolean,default:!1},size:{default:void 0},state:{type:[Boolean,null],default:void 0},debounce:{default:0},debounceMaxWait:{default:NaN}},{modelValue:{default:""},modelModifiers:{}}),emits:["update:modelValue"],setup(t,{expose:s}){const a=X(t,"BFormTextarea"),[d,r]=Se(t,"modelValue",{set:g=>ke(g,r)}),i=ie("_input"),{computedId:h,forceUpdateKey:I,computedAriaInvalid:f,onInput:$,stateClass:y,onChange:S,onBlur:V,focus:w,blur:C}=Ie(a,i,d,r),v=n(()=>[y.value,a.plaintext?"form-control-plaintext":"form-control",{[`form-control-${a.size}`]:!!a.size}]),{computedStyles:M,onInput:W,computedRows:H}=Me(i,n(()=>({maxRows:a.maxRows,rows:a.rows,noAutoShrink:a.noAutoShrink}))),z=n(()=>({resize:a.noResize?"none":void 0,...a.maxRows||a.noAutoShrink?M.value:void 0}));return s({blur:C,element:i,focus:w}),(g,o)=>(p(),E("textarea",{id:e(h),ref:"_input",key:e(I),class:D(v.value),name:e(a).name||void 0,form:e(a).form||void 0,value:e(d)??void 0,disabled:e(a).disabled,placeholder:e(a).placeholder,required:e(a).required||void 0,autocomplete:e(a).autocomplete||void 0,readonly:e(a).readonly||e(a).plaintext,"aria-required":e(a).required||void 0,"aria-invalid":e(f),rows:e(H)||2,style:Ce(z.value),wrap:e(a).wrap||void 0,onInput:o[0]||(o[0]=c=>{e($)(c),e(W)()}),onChange:o[1]||(o[1]=(...c)=>e(S)&&e(S)(...c)),onBlur:o[2]||(o[2]=(...c)=>e(V)&&e(V)(...c))},null,46,Te))}});export{He as _,fe as a,ce as b,Pe as c,ke as n,Ie as u};
