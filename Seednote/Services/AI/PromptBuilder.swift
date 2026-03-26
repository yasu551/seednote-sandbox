import Foundation

struct PromptBuilder {
    static func analysisPrompt(for text: String) -> String {
        """
        以下のテキストを分析して、要約、タイプ、質問、主張を日本語で抽出してください。
        
        テキスト:
        \(text)
        """
    }
    
    static func draftPrompt(for text: String, template: TemplateType) -> String {
        let templateDesc = template.displayName
        return """
        以下のテキストを基に、「\(templateDesc)」として再利用可能な形で生成してください。
        
        元の断片:
        \(text)
        """
    }
}
