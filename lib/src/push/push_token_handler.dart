// /**
//  * Handles generating push tokens.
//  *
//  */
// fun interface PushTokenHandler {
// /**
//  * Handles generation of a Push Token
//  *
//  * <b>Sample Usage</b>
//  * ```kotlin
//  * val tokenGenerator: PushTokenHandler = <Class Implementation>
//  *     tokenGenerator.generate(
//  *         token = { result ->
//  *             result.onSuccess {
//  *                 // handle token
//  *             }
//  *             result.onFailure {
//  *                 // Handle failure
//  *             }
//  *         }
//  *     )
//  * ```
//  *
//  * @param token A callback that returns a callback containing [Result] of a [String]
//  * */
// fun generate(token: (Result<String>) -> Unit)
// }